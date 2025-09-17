{
  osConfig,
  config,
  pkgs,
  lib,
  inputs,
  namespace,
  ...
}:
with lib.custom; let
  username = config.snowfallorg.user.name;
  home = config.snowfallorg.user.home.directory;
  impermanence = config.${namespace}.impermanence;
in
  lib.mkIf osConfig.custom.windowManagers.niri.enable {
    home.packages = with pkgs; [
      nordic
    ];

    programs.niri = {
      settings = {
        cursor.theme = "Nordic-cursors";
      };
    };
  }
