{
  pkgs,
  lib,
  osConfig,
  config,
  ...
}: let
  impermanence = config.custom.impermanence;
in {
  config = lib.mkIf osConfig.custom.presets.wayland.enable {
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
