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

      "gitlab.kylekrein.com" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
        };
      };

      "immich.kylekrein.com" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://[::1]:${toString config.services.immich.port}";
          extraConfig = ''
            client_max_body_size 10G;
          '';
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
          proxyWebsockets = true;
        };
      };
      "smart-home.kylekrein.com" = {
        forceSSL = true;
        enableACME = true;
        extraConfig = ''
          proxy_buffering off;
        '';
        locations = {
          "/" = {
            proxyPass = "http://[::1]:8123";
            proxyWebsockets = true;
          };
          "/api/prometheus" = {
            proxyPass = "http://[::1]:8123";
            proxyWebsockets = true;
            extraConfig = ''
              allow 127.0.0.1;
              allow ::1;
              deny all;
            '';
          };
        };
      };
      "grafana.kylekrein.com" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://${toString config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
          proxyWebsockets = true;
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
      "jellyfin.kylekrein.com" = {
        enableACME = true;
        forceSSL = true;
        extraConfig = ''
          ## The default `client_max_body_size` is 1M, this might not be enough for some posters, etc.
          client_max_body_size 20M;

          # Comment next line to allow TLSv1.0 and TLSv1.1 if you have very old clients
          ssl_protocols TLSv1.3 TLSv1.2;

          # Security / XSS Mitigation Headers
          add_header X-Content-Type-Options "nosniff";

          # Permissions policy. May cause issues with some clients
          add_header Permissions-Policy "accelerometer=(), ambient-light-sensor=(), battery=(), bluetooth=(), camera=(), clipboard-read=(), display-capture=(), document-domain=(), encrypted-media=(), gamepad=(), geolocation=(), gyroscope=(), hid=(), idle-detection=(), interest-cohort=(), keyboard-map=(), local-fonts=(), magnetometer=(), microphone=(), payment=(), publickey-credentials-get=(), serial=(), sync-xhr=(), usb=(), xr-spatial-tracking=()" always;

          # Content Security Policy
          add_header Content-Security-Policy "default-src https: data: blob: ; img-src 'self' https://* ; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline' https://www.gstatic.com https://www.youtube.com blob:; worker-src 'self' blob:; connect-src 'self'; object-src 'none'; font-src 'self'";
        '';

        locations."/" = {
          proxyPass = "http://127.0.0.1:8096";
          extraConfig = ''
            # Disable buffering when the nginx proxy gets very resource heavy upon streaming
            proxy_buffering off;
          '';
        };

        locations."/socket" = {
          proxyPass = "http://127.0.0.1:8096";
          proxyWebsockets = true;
        };
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "alex.lebedev2003@icloud.com";
  };
}
