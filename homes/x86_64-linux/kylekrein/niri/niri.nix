#https://github.com/sodiboo/niri-flake/blob/main/default-config.kdl.nix
#https://github.com/sodiboo/niri-flake/blob/main/docs.md
#https://github.com/sodiboo/system/blob/main/niri.mod.nix
{
  osConfig,
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib.custom; let
  username = config.snowfallorg.user.name;
  home = config.snowfallorg.user.home.directory;
in
  lib.mkIf osConfig.custom.windowManagers.niri.enable {
    custom = {
      programs.nautilus = enabled;
    };
    home.packages = with pkgs; [
      playerctl
      papers
      brightnessctl
      libnotify
      custom.wvkbd-kylekrein
      custom.lisgd-kylekrein
    ];
    programs.niri = {
      settings = {
        spawn-at-startup = [
          {
            command = [
              "${lib.getExe pkgs.custom.wvkbd-kylekrein}"
              "--hidden"
            ];
          }
          {
            command = [
              "dbus-update-activation-environment"
              "--systemd"
              "--all"
            ];
          }
          {
            command = [
              "${pkgs.solaar}/bin/solaar"
              "-w"
              "hide"
            ];
          }
        ];
        layout = {
          preset-column-widths = [
            {proportion = 1.0 / 2.0;}
            {proportion = 1.0;}
            {proportion = 2.0 / 3.0;}
            {proportion = 1.0 / 3.0;}
          ];
          default-column-width = {proportion = 1.0 / 2.0;};
        };
        binds = with config.lib.niri.actions; let
          sh = spawn "sh" "-c";
          emacs = action: sh "emacsclient -c --eval \"${action}\"";
          screenshot-annotate = sh ''${lib.getExe pkgs.grim} -g "$(${lib.getExe pkgs.slurp} -w 0)" -t ppm - | ${lib.getExe pkgs.satty} --early-exit --copy-command 'wl-copy' --filename='-' -o '~/Pictures/Screenshots/Screenshot-%Y-%m-%d_%H:%M:%S.png' --initial-tool brush'';
        in {
          "Mod+E".action = sh "emacsclient -c";
          "Mod+Shift+C".action = sh "nautilus";
          "Mod+C".action = emacs ''(dirvish \"${home}\")'';
          "Mod+T".action = spawn "kitty";
          "Mod+B".action = spawn "librewolf";
          "Mod+H".action = show-hotkey-overlay;
          "Mod+F".action = fullscreen-window;
          "Mod+R".action = switch-preset-column-width;
          "Mod+Q".action = close-window;
          "Mod+Shift+S".action = screenshot-annotate;
          "Mod+1".action = focus-workspace 1;
          "Mod+2".action = focus-workspace 2;
          "Mod+3".action = focus-workspace 3;
          "Mod+4".action = focus-workspace 4;
          "Mod+5".action = focus-workspace 5;
          "Mod+6".action = focus-workspace 6;
          "Mod+7".action = focus-workspace 7;
          "Mod+8".action = focus-workspace 8;
          "Mod+9".action = focus-workspace 9;
          "Mod+0".action = focus-workspace 10;

          "Mod+Shift+1".action.move-column-to-workspace = 1;
          "Mod+Shift+2".action.move-column-to-workspace = 2;
          "Mod+Shift+3".action.move-column-to-workspace = 3;
          "Mod+Shift+4".action.move-column-to-workspace = 4;
          "Mod+Shift+5".action.move-column-to-workspace = 5;
          "Mod+Shift+6".action.move-column-to-workspace = 6;
          "Mod+Shift+7".action.move-column-to-workspace = 7;
          "Mod+Shift+8".action.move-column-to-workspace = 8;
          "Mod+Shift+9".action.move-column-to-workspace = 9;
          "Mod+Shift+0".action.move-column-to-workspace = 10;

          "Mod+Left".action = focus-column-left;
          "Mod+Right".action = focus-column-right;
          "Mod+Up".action = focus-workspace-up;
          "Mod+Down".action = focus-workspace-down;
          "Mod+Shift+Left".action = move-column-left;
          "Mod+Shift+Right".action = move-column-right;
          "Mod+Shift+Up".action = move-column-to-workspace-up;
          "Mod+Shift+Down".action = move-column-to-workspace-down;
          "Mod+Ctrl+Left".action = focus-monitor-left;
          "Mod+Ctrl+Right".action = focus-monitor-right;
          "Mod+Shift+Ctrl+Left".action = move-column-to-monitor-left;
          "Mod+Shift+Ctrl+Right".action = move-column-to-monitor-right;

          "Ctrl+Alt+Delete" = {
            hotkey-overlay.title = "Restart Desktop Shell";
            action.spawn = [
              "systemctl"
              "--user"
              "restart"
              "desktop-shell.service"
            ];
          };

          "Mod+Space" = {
            hotkey-overlay.title = "App Launcher";
            action.spawn = [
              "qs"
              "-c"
              "DankMaterialShell"
              "ipc"
              "call"
              "spotlight"
              "toggle"
            ];
          };
          "Mod+V" = {
            hotkey-overlay.title = "Clipboard Manager";
            action.spawn = [
              "qs"
              "-c"
              "DankMaterialShell"
              "ipc"
              "call"
              "clipboard"
              "toggle"
            ];
          };
          "Mod+M" = {
            hotkey-overlay.title = "System Monitor";
            action.spawn = [
              "qs"
              "-c"
              "DankMaterialShell"
              "ipc"
              "call"
              "processlist"
              "toggle"
            ];
          };
          "Mod+Comma" = {
            hotkey-overlay.title = "Open Settings";
            action.spawn = [
              "qs"
              "-c"
              "DankMaterialShell"
              "ipc"
              "call"
              "settings"
              "toggle"
            ];
          };
          "Super+L" = {
            hotkey-overlay.title = "Lock";
            action.spawn = [
              "qs"
              "-c"
              "DankMaterialShell"
              "ipc"
              "call"
              "lock"
              "lock"
            ];
          };
          "XF86AudioRaiseVolume" = {
            allow-when-locked = true;
            hotkey-overlay.hidden = true;
            action.spawn = [
              "qs"
              "-c"
              "DankMaterialShell"
              "ipc"
              "call"
              "audio"
              "increment"
              "3"
            ];
          };
          "XF86AudioLowerVolume" = {
            allow-when-locked = true;
            hotkey-overlay.hidden = true;
            action.spawn = [
              "qs"
              "-c"
              "DankMaterialShell"
              "ipc"
              "call"
              "audio"
              "decrement"
              "3"
            ];
          };
          "XF86AudioMute" = {
            allow-when-locked = true;
            hotkey-overlay.hidden = true;
            action.spawn = [
              "qs"
              "-c"
              "DankMaterialShell"
              "ipc"
              "call"
              "audio"
              "mute"
            ];
          };
          "XF86AudioMicMute" = {
            allow-when-locked = true;
            hotkey-overlay.hidden = true;
            action.spawn = [
              "qs"
              "-c"
              "DankMaterialShell"
              "ipc"
              "call"
              "audio"
              "micmute"
            ];
          };

          "XF86MonBrightnessUp" = {
            allow-when-locked = true;
            hotkey-overlay.hidden = true;
            action.spawn = [
              "qs"
              "-c"
              "DankMaterialShell"
              "ipc"
              "call"
              "brightness"
              "increment"
              "5"
              ""
            ];
          };
          "XF86MonBrightnessDown" = {
            allow-when-locked = true;
            hotkey-overlay.hidden = true;
            action.spawn = [
              "qs"
              "-c"
              "DankMaterialShell"
              "ipc"
              "call"
              "brightness"
              "decrement"
              "5"
              ""
            ];
          };

          "XF86AudioNext" = {
            allow-when-locked = true;
            hotkey-overlay.hidden = true;
            action = sh "playerctl next";
          };
          "XF86AudioPause" = {
            allow-when-locked = true;
            hotkey-overlay.hidden = true;
            action = sh "playerctl play-pause";
          };
          "XF86AudioPlay" = {
            allow-when-locked = true;
            hotkey-overlay.hidden = true;
            action = sh "playerctl play-pause";
          };
          "XF86AudioPrev" = {
            allow-when-locked = true;
            hotkey-overlay.hidden = true;
            action = sh "playerctl previous";
          };
          #"Mod+Tab".action = focus-window-down-or-column-right;
          #"Mod+Shift+Tab".action = focus-window-up-or-column-left;
          "Mod+Tab".action = toggle-overview;
        };
        input = {
          power-key-handling.enable = !osConfig.custom.hardware.hibernation.enable;
          focus-follows-mouse = {
            #enable = true;
          };
          warp-mouse-to-focus.enable = false;
          keyboard = {
            xkb.layout = "eu, ru";
            xkb.options = "grp:lctrl_toggle, ctrl:nocaps";
            track-layout = "window";
            numlock = true;
          };
          touchpad = {
            tap = true;
            #accel-profile = "adaptive";
            click-method = "clickfinger";
          };
        };
        cursor = {
          hide-after-inactive-ms = 10000;
        };
        gestures.hot-corners.enable = true;
        prefer-no-csd = true;
        environment = {
          XDG_SESSION_TYPE = "wayland";
          __GL_GSYNC_ALLOWED = "1";
          QT_QPA_PLATFORM = "wayland";
          DISPLAY = ":0";
        };
        layer-rules = [
          {
            #this is for later to place keyboard on top of hyprlock
            matches = [{namespace = "wvkbd";}];
          }
        ];
        window-rules = [
          {
            #active
            matches = [
              {
                is-active = true;
              }
            ];
            opacity = 1.0;
          }
          {
            #inactive
            matches = [
              {
                is-active = false;
              }
            ];
            opacity = 1.0;
          }
          {
            #opaque
            matches = [
              {
                app-id = "emacs";
              }
              {
                app-id = "blender";
              }
            ];
            opacity = 1.0;
          }
          {
            #Popups
            matches = [
              {
                title = "emacs-run-launcher";
              }
              {
                title = "Paradox Crash Reporter";
              }
            ];
            open-floating = true;
            open-focused = true;
          }
          {
            #PiP
            matches = [
              {
                title = "Picture-in-Picture";
              }
            ];
            open-floating = true;
            open-focused = false;
            opacity = 1.0;
            default-floating-position = {
              x = 0;
              y = 0;
              relative-to = "top-right";
            };
          }
        ];
        xwayland-satellite = {
          enable = true;
          path = "${lib.getExe pkgs.xwayland-satellite-stable}";
        };
      };
    };

    services.hypridle = let
      niri = lib.getExe config.programs.niri.package;
      loginctl = "${pkgs.systemd}/bin/loginctl";
      qs = "${inputs.quickshell.packages.${pkgs.system}.quickshell}/bin/qs";
      locking-script = "${qs} -c DankMaterialShell ipc call lock lock";
      systemctl = "${pkgs.systemd}/bin/systemctl";
      suspendScript = cmd:
        pkgs.writeShellScript "suspend-script" ''
          # check if any player has status "Playing"
          ${lib.getExe pkgs.playerctl} -a status | ${lib.getExe pkgs.ripgrep} Playing -q
          # only suspend if nothing is playing
          if [ $? == 1 ]; then
             ${cmd}
          fi
        '';
    in {
      enable = true;
      settings.general = {
        before_sleep_cmd = "${loginctl} lock-session";
        #after_sleep_cmd = "#${niri} msg action power-on-monitors";
        lock_cmd = "${locking-script}";
        ignore_dbus_inhibit = false; # whether to ignore dbus-sent idle-inhibit requests (used by e.g. firefox or steam)
        ignore_systemd_inhibit = false; # whether to ignore systemd-inhibit --what=idle inhibitors
      };
      settings.listener = let
        secondary = "${systemctl} suspend";
      in [
        #{
        #  timeout = 30;
        #  command = "pidof hyprlock && ${secondary}";
        #}
        {
          timeout = 870;
          on-timeout = "${suspendScript ''${pkgs.libnotify}/bin/notify-send "You are idle. Going to sleep in 30 seconds"''}";
        }
        {
          timeout = 900;
          on-timeout = "${suspendScript "${systemctl} suspend"}";
        }
      ];
    };
    systemd.user.services.lisgd-niri = lib.mkIf (config.custom.hardware.tablet.enable) {
      Unit = {
        Description = "Makes sure that you have touchscreen gestures.";
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
      Service = {
        ExecStart = "${pkgs.writeShellScript "run-lisgd" ''
          ${pkgs.custom.lisgd-kylekrein}/bin/lisgd
        ''}";
        Restart = "always";
        RestartSec = 5;
      };
    };
    systemd.user.services.autorotate-niri = lib.mkIf (config.custom.hardware.tablet.enable) {
      Unit = {
        Description = "Adds auto rotation to Niri.";
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
      Service = {
        ExecStart = "${pkgs.writeShellScript "autorotate" ''
            transform="normal"

            monitor-sensor | while read -r line; do
              case "$line" in
                *normal*)
                  new_transform="normal"
                  ;;
                *right-up*)
                  new_transform="270"
                  ;;
                *bottom-up*)
                  new_transform="180"
                      ;;
                *left-up*)
                  new_transform="90"
                  ;;
                *)
                  continue
                  ;;
              esac

              if [[ "$new_transform" != "$transform" ]]; then
                transform="$new_transform"
                echo "Transform: $transform"
                niri msg output eDP-1 transform "$transform"
                systemctl --user restart lisgd-niri.service
              fi
          done
        ''}";
        Restart = "always";
        RestartSec = 5;
      };
    };
    custom.hardware.tablet = {
      onTabletModeEnable = [
        {
          name = "autorotate";
          command = "systemctl --user start autorotate-niri.service";
        }
      ];
      onTabletModeDisable = [
        {
          name = "autorotate";
          command = ''
            systemctl --user stop autorotate-niri.service
            niri msg output eDP-1 transform normal
          '';
        }
      ];
    };
  }
