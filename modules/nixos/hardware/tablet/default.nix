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
    systemd.services =
      {
        tablet-mode-watcher = {
          description = "Watch for tablet mode changes";
          serviceConfig = {
            ExecStart = "${pkgs.writeShellScript "tablet-mode-eventd" ''
in_tablet_mode=$(${pkgs.coreutils}/bin/cat "${cfg.path}" 2>/dev/null || $(echo 0 > "${cfg.path}" && echo 0))

stdbuf -oL -eL ${lib.getExe pkgs.libinput} debug-events --device "${cfg.inputDevice}" | while read -r line; do
  if [[ "$line" =~ switch\ tablet-mode\ state\ ([01]) ]]; then
    d="''${BASH_REMATCH[1]}"
    if [ "$d" -ne "$in_tablet_mode" ]; then
      in_tablet_mode=$d
      if [ "$d" -eq 1 ]; then
        systemctl start tablet-on.target
	echo "Tablet mode ON"
        echo 1 > "${cfg.path}"
      else
        systemctl start tablet-off.target
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
      }
      // (lib.listToAttrs (map (cmd: {
          name = "tablet-action-on-${cmd.name}";
          value = {
            Unit.PartOf = ["tablet-on.target"];
            Service = {
              Type = "oneshot";
              ExecStart = "sh -c ${cmd.command}";
            };
            Install.WantedBy = ["tablet-on.target"];
          };
        })
        cfg.onTabletModeEnable))
      // (lib.listToAttrs (map (cmd: {
          name = "tablet-action-off-${cmd.name}";
          value = {
            Unit.PartOf = ["tablet-off.target"];
            Service = {
              Type = "oneshot";
              ExecStart = "sh -c ${cmd.command}";
            };
            Install.WantedBy = ["tablet-off.target"];
          };
        })
        cfg.onTabletModeDisable));

    # 2. System targets
    systemd.targets.tablet-on = {};
    systemd.targets.tablet-off = {};
  };
}
