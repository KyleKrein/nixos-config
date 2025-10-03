{
  pkgs,
  lib,
  osConfig,
  ...
}: let
  impermanence = config.custom.impermanence;
in {
  config = lib.optionals osConfig.custom.presets.wayland.enable {
    home.packages = with pkgs; [
      lrcget
      picard
      beets
    ];
    home.persistence = lib.mkIf impermanence.enable {
      "${impermanence.persistentStorage}".directories = [
        ".config/MusicBrainz"
        ".config/beets"
      ];
    };
  };
}
