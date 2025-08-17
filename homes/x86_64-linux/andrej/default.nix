{
  lib,
  pkgs,
  config,
  ...
}:
# User information gathered by Snowfall Lib is available.
let
  name = config.snowfallorg.user.name;
  home = config.snowfallorg.user.home.directory;
in {
  imports = lib.snowfall.fs.get-non-default-nix-files ./.;
  custom = {
    programs.librewolf.enable = true;
  };
  services.flatpak.packages = [
    "org.vinegarhq.Sober"
  ];
  home = {
    packages = with pkgs; [
      zapzap
    ];

    sessionVariables = {
    };

    stateVersion = "24.11";
  };
}
