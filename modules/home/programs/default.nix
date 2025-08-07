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
  cfg = config.${namespace}.programs.fastfetch;
in {
  options.${namespace}.programs.fastfetch = with types; {
    enable = mkBoolOpt false "Enable fastfetch with custom settings";
    firstNixOSInstall = mkOption {
      type = nullOr int;
      default = null;
      description = ''
        Unix time of the first install of NixOS to use for age. Can be aquired with "stat -c %W /"
      '';
    };
  };

  config = mkIf cfg.enable {
    programs.fastfetch = {
      enable = true;

      settings = {
        display = {
          color = {
            keys = "35";
            output = "1000";
          };
        };

        logo = {
          source = ./nixos.png;
          type = "kitty-direct";
          height = 15;
          width = 30;
          padding = {
            top = 3;
            left = 3;
          };
        };

        modules = [
          "break"
          {
            type = "custom";
            format = "┌──────────────────────Hardware──────────────────────┐";
          }
          {
            type = "cpu";
            key = "│  ";
          }
          {
            type = "gpu";
            key = "│ 󰍛 ";
          }
          {
            type = "memory";
            key = "│ 󰑭 ";
          }
          {
            type = "custom";
            format = "└────────────────────────────────────────────────────┘";
          }
          "break"
          {
            type = "custom";
            format = "┌──────────────────────Software──────────────────────┐";
          }
          {
            type = "custom";
            format = " OS -> NixOS btw";
          }
          {
            type = "kernel";
            key = "│ ├ ";
          }
          {
            type = "packages";
            key = "│ ├󰏖 ";
          }
          {
            type = "shell";
            key = "└ └ ";
          }
          "break"
          {
            type = "wm";
            key = " WM";
          }
          {
            type = "wmtheme";
            key = "│ ├󰉼 ";
          }
          {
            type = "terminal";
            key = "└ └ ";
          }
          {
            type = "custom";
            format = "└────────────────────────────────────────────────────┘";
          }
          "break"
          {
            type = "custom";
            format = "┌────────────────────Age / Uptime────────────────────┐";
          }
          {
            type = "command";
            key = "│  ";
            text =
              #bash
              ''
                birth_install=${
                  if cfg.firstNixOSInstall != null
                  then "${builtins.toString cfg.firstNixOSInstall}"
                  else "$(stat -c %W /)"
                }
                current=$(date +%s)
                delta=$((current - birth_install))
                delta_days=$((delta / 86400))
                echo $delta_days days
              '';
          }
          {
            type = "uptime";
            key = "│  ";
          }
          {
            type = "custom";
            format = "└────────────────────────────────────────────────────┘";
          }
          "break"
        ];
      };
    };
  };
}
