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
  home = {
    packages = with pkgs; [
      librewolf
    ];

    sessionVariables = {
      EDITOR = "emacsclient -c";
    };

    stateVersion = "25.05";
  };
}
