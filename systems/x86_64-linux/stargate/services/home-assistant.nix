{
  pkgs,
  lib,
  config,
  ...
}: {
  services.home-assistant = {
    enable = true;
    extraComponents = [
      # Components required to complete the onboarding
      "esphome"
      "met"
      "radio_browser"
      "wiz"
    ];
    config = {
      http = {
        server_host = "::1";
        trusted_proxies = ["::1"];
        use_x_forwarded_for = true;
      };
      prometheus = {
        namespace = "hass";
        requires_auth = false;
      };
      recorder.db_url = "postgresql://@/hass";
      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = {};
    };
  };
  services.home-assistant = {
    package =
      (pkgs.home-assistant.override {
        extraPackages = py: with py; [psycopg2];
      }).overrideAttrs (oldAttrs: {
        doInstallCheck = false;
      });
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = ["hass"];
    ensureUsers = [
      {
        name = "hass";
        ensureDBOwnership = true;
      }
    ];
  };
}
