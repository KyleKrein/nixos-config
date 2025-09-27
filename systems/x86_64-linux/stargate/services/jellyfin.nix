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
with lib.custom; {
  sops.secrets."services/jellyfin" = {
    owner = config.services.jellyfin.user;
    group = config.services.jellyfin.group;
  };
  services.declarative-jellyfin = {
    enable = true;
    openFirewall = true;
    users = {
      admin = {
        mutable = false;
        permissions.isAdministrator = true;
        hashedPasswordFile = config.sops.secrets."services/jellyfin".path;
      };
    };
    plugins = [
      {
        name = "intro skipper";
        url = "https://github.com/intro-skipper/intro-skipper/releases/download/10.10/v1.10.10.19/intro-skipper-v1.10.10.19.zip";
        version = "1.10.10.19";
        targetAbi = "10.10.7.0"; # Required as intro-skipper doesn't provide a meta.json file
        sha256 = "sha256:12hby8vkb6q2hn97a596d559mr9cvrda5wiqnhzqs41qg6i8p2fd";
      }
    ];
    system = {
      serverName = "Jellyfin Homeserver for Bees";
      # Use Hardware Acceleration for trickplay image generation
      trickplayOptions = {
        enableHwAcceleration = true;
        enableHwEncoding = true;
      };
      UICulture = "ru";
    };
    encoding = {
      enableHardwareEncoding = true;
      hardwareAccelerationType = "vaapi";
      enableDecodingColorDepth10Hevc = true; # enable if your system supports
      allowHevcEncoding = true; # enable if your system supports
      allowAv1Encoding = true; # enable if your system supports
      hardwareDecodingCodecs = [
        # enable the codecs your system supports
        "h264"
        "hevc"
        "mpeg2video"
        "vc1"
        "vp9"
        "av1"
      ];
    };
  };
  users.users.${config.services.jellyfin.user}.extraGroups = ["video" "render"];
}
