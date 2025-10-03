{
  pkgs,
  lib,
  config,
  ...
}: {
  systemd.services.navidrome.serviceConfig.ExecStart = with lib; let
    cfg = config.services.navidrome;
    settingsFormat = pkgs.formats.toml {};
  in
    mkForce ''
      ${pkgs.bash}/bin/bash -c "${getExe cfg.package} --configfile '${settingsFormat.generate "navidrome.toml" cfg.settings}'"
    '';
  services.navidrome = {
    enable = true;
    settings = {
      Scanner.Schedule = "@every 24h";
      MusicFolder = "/zstorage/media/music";
      EnableSharing = true;
      BaseUrl = "https://music.kylekrein.com";
      FFmpegPath = "${pkgs.ffmpeg}/bin/ffmpeg";
    };
  };
}
