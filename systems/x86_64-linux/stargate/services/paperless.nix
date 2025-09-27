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
  sops.secrets."services/paperless" = {owner = config.services.paperless.user;};
  services.paperless = {
    enable = true;
    passwordFile = config.sops.secrets."services/paperless".path;
    consumptionDirIsPublic = false;
    database.createLocally = true;
    settings = {
      PAPERLESS_CONSUMER_IGNORE_PATTERN = [
        ".DS_STORE/*"
        "desktop.ini"
      ];
      PAPERLESS_OCR_LANGUAGE = "deu+eng+rus";
      PAPERLESS_OCR_USER_ARGS = {
        optimize = 1;
        pdfa_image_compression = "lossless";
      };
      PAPERLESS_URL = "https://paperless.kylekrein.com";
    };
  };
}
