{
  lib,
  pkgs,
  config,
  osConfig ? {},
  ...
}: let
  name = config.snowfallorg.user.name;
  home = config.snowfallorg.user.home.directory;
in
  with lib;
  with lib.custom; {
    imports = lib.snowfall.fs.get-non-default-nix-files-recursive ./.;
    custom = {
      programs = {
        fastfetch = {
          enable = true;
          firstNixOSInstall = 1729112485;
        };
        librewolf = enabled;
        prismlauncher.enable = osConfig.custom.presets.gaming.enable;
        bottles = enabled;
      };
    };
    home = {
      packages = with pkgs;
        [
          gdb
          element-desktop
          obs-studio
          neovim
          localsend
          kdePackages.kdenlive
        ]
        ++ lib.optionals osConfig.custom.presets.gaming.enable [mcpelauncher-ui-qt];

      sessionVariables = {
        EDITOR = "emacsclient -c";
        NH_OS_FLAKE = "${home}/nixos-config";
        NH_HOME_FLAKE = "${home}/nixos-config";
        NH_DARWIN_FLAKE = "${home}/nixos-config";
      };

      stateVersion = "25.05";
    };
  }
