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
  services.caddy = {
    enable = true;
    #virtualHosts."kylekrein.com:8448".extraConfig = ''
    #  reverse_proxy http://localhost:6167
    #'';
    virtualHosts."kylekrein.com".extraConfig = config.services.caddy.virtualHosts."matrix.kylekrein.com".extraConfig;
    #  reverse_proxy /.well-known/* http://localhost:6167
    #'';
    virtualHosts."matrix.kylekrein.com".extraConfig = ''
      handle_path /.well-known/matrix/* {

          header Access-Control-Allow-Origin *

          ## `Content-Type: application/json` isn't required by the matrix spec
          ## but some browsers (firefox) and some other tooling might preview json
          ## content prettier when they are made aware via Content-Type
          header Content-Type application/json

          respond /client `{ "m.homeserver": { "base_url": "https://matrix.kylekrein.com/" }, "org.matrix.msc3575.proxy": { "url": "https://matrix.kylekrein.com/"}, "org.matrix.msc4143.rtc_foci": [ { "type": "livekit", "livekit_service_url": "https://livekit-jwt.call.matrix.org" } ] }`

          respond /server `{ "m.server": "matrix.kylekrein.com:443" }`

          ## return http/404 if nothing matches
          respond 404
      }
      respond /.well-known/element/element.json `{"call":{"widget_url":"https://call.element.io"}}`
          reverse_proxy * http://localhost:6167
    '';
    virtualHosts."gitlab.kylekrein.com".extraConfig = ''
      reverse_proxy * unix//run/gitlab/gitlab-workhorse.socket
    '';
    virtualHosts."immich.kylekrein.com".extraConfig = ''
      reverse_proxy * http://[::1]:${toString config.services.immich.port}
    '';
    virtualHosts."nextcloud.kylekrein.com".extraConfig = ''
      reverse_proxy * http://nextcloud.localhost"
    '';
    virtualHosts."ntfy.kylekrein.com".extraConfig = ''
      reverse_proxy * http://[::1]${config.services.ntfy-sh.settings.listen-http}
    '';
  };
}
