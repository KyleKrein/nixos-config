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
        librewolf.enable = osConfig.custom.presets.wayland.enable;
        prismlauncher.enable = osConfig.custom.presets.gaming.enable;
        bottles.enable = osConfig.custom.presets.wayland.enable;
      };
    };
    programs.nheko.enable = custom.presets.wayland.enable;
    home = {
      packages = with pkgs;
        [
          neovim
        ]
        ++ lib.optionals osConfig.custom.presets.wayland.enable [
          gdb
          element-desktop
          obs-studio
          localsend
          kdePackages.kdenlive
        ]
        ++ lib.optionals osConfig.custom.presets.gaming.enable [mcpelauncher-ui-qt];

      sessionVariables = {
        EDITOR =
          if osConfig.custom.presets.wayland.enable
          then "emacsclient -c"
          else "nvim";
        NH_OS_FLAKE = "${home}/nixos-config";
        NH_HOME_FLAKE = "${home}/nixos-config";
        NH_DARWIN_FLAKE = "${home}/nixos-config";
      };

      stateVersion = "25.05";
    };
  }
