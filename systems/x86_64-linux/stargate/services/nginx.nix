{
  lib,
  pkgs,
  config,
  ...
}: let
  matrixLocations = {
    "~ ^/\\.well-known/matrix/client$" = {
      extraConfig = ''
        add_header Access-Control-Allow-Origin *;
        add_header Content-Type application/json;
        return 200 '{"m.homeserver": { "base_url": "https://matrix.kylekrein.com/" }, "org.matrix.msc3575.proxy": { "url": "https://matrix.kylekrein.com/"}, "org.matrix.msc4143.rtc_foci": [ { "type": "livekit", "livekit_service_url": "https://livekit-jwt.call.matrix.org" } ] }';
      '';
    };
    "~ ^/\\.well-known/matrix/server$" = {
      extraConfig = ''
        add_header Content-Type application/json;
        return 200 '{"m.server": "matrix.kylekrein.com:443"}';
      '';
    };
    "~ ^/\\.well-known/element/element.json$" = {
      extraConfig = ''
        add_header Content-Type application/json;
        return 200 '{"call":{"widget_url":"https://call.element.io"}}';
      '';
    };
    "/" = {
      proxyPass = "http://127.0.0.1:6167";
    };
  };
in {
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedGzipSettings = true;

    virtualHosts = {
      # "kylekrein.com" = {
      #  enableACME = true;
      # forceSSL = true;
      #locations = config.services.nginx.virtualHosts."matrix.kylekrein.com".locations;
      #};

      #"matrix.kylekrein.com" = {
      #  enableACME = true;
      #  forceSSL = true;
      #  locations = matrixLocations;
      #};

      #"gitlab.kylekrein.com" = {
      #  enableACME = true;
      #  forceSSL = true;
      #  locations."/" = {
      #    proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
      #  };
      #};

      "immich.kylekrein.com" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://[::1]:${toString config.services.immich.port}";
        };
      };

      "${config.services.nextcloud.hostName}" = {
        enableACME = true;
        forceSSL = true;
      };

      "ntfy.kylekrein.com" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://[::1]${config.services.ntfy-sh.settings.listen-http}";
        };
      };
      "paperless.kylekrein.com" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = let
          cfg = config.services.paperless;
        in {
          proxyPass = "http://${cfg.address}:${builtins.toString cfg.port}";
        };
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "alex.lebedev2003@icloud.com";
  };
}
