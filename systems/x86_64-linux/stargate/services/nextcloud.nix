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
  sops.secrets."services/nextcloud" = {owner = "nextcloud";};
  services.nextcloud = {
    enable = true;
    database.createLocally = true;
    config = {
      dbtype = "pgsql";
      adminpassFile = config.sops.secrets."services/nextcloud".path;
    };
    hostName = "nextcloud.kylekrein.com";
    https = true;
  };
}
