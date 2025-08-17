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
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.hardware.tablet;
in {
  options.${namespace}.hardware.tablet = with types; {
    enable = mkBoolOpt false "Enable tablet module for hardware that supports it";
    path = mkOpt path "/run/tablet-mode-state" "Path with a file, where it's stated, whether tablet mode 'on' or 'off'";
    inputDevice = mkOpt' str "/dev/input/event4";
    onTabletModeEnable = mkOpt (listOf (attrsOf str)) [] "Actions to do when entering tablet mode";
    onTabletModeDisable = mkOpt (listOf (attrsOf str)) [] "Actions to do when exiting tablet mode";
  };

  config = mkIf cfg.enable {
    # 1. System service for watching
    systemd.services = {
      tablet-mode-watcher = {
        description = "Watch for tablet mode changes";
        serviceConfig = {
          ExecStart = "${pkgs.writeShellScript "tablet-mode-eventd" ''
            if [ -f "${cfg.path}" ]; then
                     in_tablet_mode=$(${pkgs.coreutils}/bin/cat "${cfg.path}")
                   else
                     echo 0 > "${cfg.path}"
                     in_tablet_mode=0
                   fi

                   stdbuf -oL -eL ${lib.getExe pkgs.libinput} debug-events --device "${cfg.inputDevice}" | while read -r line; do
                     if [[ "$line" =~ switch\ tablet-mode\ state\ ([01]) ]]; then
                       d="''${BASH_REMATCH[1]}"
                       if [ "$d" -ne "$in_tablet_mode" ]; then
                         in_tablet_mode=$d
                         if [ "$d" -eq 1 ]; then
                           ${concatStringsSep "\n" (map (cmd: ''
                systemd-run --unit=tablet-on-${cmd.name} --collect sh -c '${cmd.command}'
              '')
              cfg.onTabletModeEnable)}
                   	echo "Tablet mode ON"
                           echo 1 > "${cfg.path}"
                         else
                           ${concatStringsSep "\n" (map (cmd: ''
                systemd-run --unit=tablet-off-${cmd.name} --collect sh -c '${cmd.command}'
              '')
              cfg.onTabletModeDisable)}
                   	echo "Tablet mode OFF"
                           echo 0 > "${cfg.path}"
                         fi
                       fi
                     fi
                   done
          ''}";
          Restart = "always";
        };
        wantedBy = ["graphical.target"];
      };
    };
  };
}
