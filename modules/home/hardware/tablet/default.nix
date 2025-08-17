{
  lib,
  pkgs,
  inputs,
  namespace,
  system,
  target,
  format,
  virtual,
  systems,
  config,
  osConfig,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.hardware.tablet;
  osCfg = osConfig.${namespace}.hardware.tablet;
in {
  options.${namespace}.hardware.tablet = with types; {
    enable = mkBoolOpt osCfg.enable "Enable tablet module for hardware that supports it";
    path = mkOpt path osCfg.path "Path with a file, where it's stated, whether tablet mode 'on' or 'off'";
    onTabletModeEnable = mkOpt (listOf (attrsOf str)) [] "Actions to do when entering tablet mode. Should have name and command string attributes.";
    onTabletModeDisable = mkOpt (listOf (attrsOf str)) [] "Actions to do when exiting tablet mode. Should have name and command string attributes.";
  };

  config = mkIf cfg.enable {
    systemd.user.services.tablet-mode-watcher = {
      Service = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "tablet-mode-watcher" ''
          state=$(${pkgs.coreutils}/bin/cat "${cfg.path}" 2>/dev/null || echo 0)

          if [ "$state" -eq 1 ]; then
            echo "Tablet mode ON"
            ${concatStringsSep "\n" (map (cmd: ''
              systemd-run --user --unit=tablet-on-${cmd.name} --collect sh -c '${cmd.command}'
            '')
            cfg.onTabletModeEnable)}
          else
            echo "Tablet mode OFF"
            ${concatStringsSep "\n" (map (cmd: ''
              systemd-run --user --unit=tablet-off-${cmd.name} --collect sh -c '${cmd.command}'
            '')
            cfg.onTabletModeDisable)}
          fi
        '';
      };
    };

    systemd.user.paths.tablet-mode-watcher = {
      Unit.Description = "Watch for tablet mode changes";
      Path.PathChanged = cfg.path;
      Install.WantedBy = ["default.target"];
    };
  };
}
