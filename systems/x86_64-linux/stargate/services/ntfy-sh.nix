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
  services.ntfy-sh = {
    enable = true;
    settings = {
      base-url = "https://ntfy.kylekrein.com";
      listen-http = ":9000";
      auth-default-access = "deny-all";
      behind-proxy = true;
      enable-login = false;
    };
  };
}
