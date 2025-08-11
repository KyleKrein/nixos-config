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
  imports = lib.snowfall.fs.get-non-default-nix-files ./.;
  custom = {
    presets.default = enabled;
    users.kylekrein = {
      enable = true;
      config = {};
    };
    services.conduwuit = {
      enable = true;
      #user = "turnserver";
      settings = {
        global = {
          server_name = "kylekrein.com";
          well_known = {
            server = "matrix.kylekrein.com:443";
            client = "https://matrix.kylekrein.com";
          };
          port = [6167];
          trusted_servers = ["matrix.org"];
          allow_registration = false;
          registration_token = null; #nix shell nixpkgs#openssl -c openssl rand -base64 48 | tr -d '/+' | cut -c1-64
          allow_federation = true;
          allow_encryption = true;

          allow_local_presence = true;
          require_auth_for_profile_requests = true;
        };
      };
      extraEnvironment = {
      };
    };
  };

  services.caddy = {
    enable = true;
    #virtualHosts."kylekrein.com:8448".extraConfig = ''
    #  reverse_proxy http://localhost:6167
    #'';
    virtualHosts."kylekrein.com".extraConfig = ''
      handle_path /.well-known/matrix/* {

          header Access-Control-Allow-Origin *

          ## `Content-Type: application/json` isn't required by the matrix spec
          ## but some browsers (firefox) and some other tooling might preview json
          ## content prettier when they are made aware via Content-Type
          header Content-Type application/json

          respond /client `{ "m.homeserver": { "base_url": "https://matrix.kylekrein.com/" }, "org.matrix.msc3575.proxy": { "url": "https://matrix.kylekrein.com/"}, "org.matrix.msc4143.rtc_foci": [ { "type": "livekit", "livekit_service_url": "https://livekit-jwt.call.matrix.org" } ] }`

          respond /server `{ "m.server": "https://matrix.kylekrein.com" }`

          ## return http/404 if nothing matches
          respond 404
      }
      respond /.well-known/element/element.json `{"call":{"widget_url":"https://call.element.io"}}`
          reverse_proxy * http://localhost:6167
    '';
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

          respond /server `{ "m.server": "https://matrix.kylekrein.com" }`

          ## return http/404 if nothing matches
          respond 404
      }
      respond /.well-known/element/element.json `{"call":{"widget_url":"https://call.element.io"}}`
          reverse_proxy * http://localhost:6167
    '';
    virtualHosts."gitlab.kylekrein.com".extraConfig = ''
      reverse_proxy * unix//run/gitlab/gitlab-workhorse.socket
    '';
  };

  #Chat host
  networking.firewall.allowedTCPPorts = [80 443 22 8448];
  networking.firewall.allowedUDPPorts = [3478 5349];
  #sops.secrets."services/conduwuit" = {mode = "0755";};

  sops.secrets."services/gitlab/dbPassword" = {owner = "gitlab";};
  sops.secrets."services/gitlab/rootPassword" = {owner = "gitlab";};
  sops.secrets."services/gitlab/secret" = {owner = "gitlab";};
  sops.secrets."services/gitlab/otpsecret" = {owner = "gitlab";};
  sops.secrets."services/gitlab/dbsecret" = {owner = "gitlab";};
  sops.secrets."services/gitlab/oidcKeyBase" = {owner = "gitlab";};
  sops.secrets."services/gitlab/activeRecordSalt" = {owner = "gitlab";};
  sops.secrets."services/gitlab/activeRecordPrimaryKey" = {owner = "gitlab";};
  sops.secrets."services/gitlab/activeRecordDeterministicKey" = {owner = "gitlab";};
  services.gitlab = {
    enable = true;
    host = "gitlab.kylekrein.com";
    port = 443;
    #statePath = "/persist/gitlab/state";
    backup.startAt = "3:00";
    databasePasswordFile = config.sops.secrets."services/gitlab/dbPassword".path;
    initialRootPasswordFile = config.sops.secrets."services/gitlab/rootPassword".path;
    secrets = {
      secretFile = config.sops.secrets."services/gitlab/secret".path;
      otpFile = config.sops.secrets."services/gitlab/otpsecret".path;
      dbFile = config.sops.secrets."services/gitlab/dbsecret".path;
      jwsFile = config.sops.secrets."services/gitlab/oidcKeyBase".path; #pkgs.runCommand "oidcKeyBase" {} "${pkgs.openssl}/bin/openssl genrsa 2048 > $out";
      activeRecordSaltFile = config.sops.secrets."services/gitlab/activeRecordSalt".path;
      activeRecordPrimaryKeyFile = config.sops.secrets."services/gitlab/activeRecordPrimaryKey".path;
      activeRecordDeterministicKeyFile = config.sops.secrets."services/gitlab/activeRecordDeterministicKey".path;
    };
  };

  systemd.services.gitlab-backup.environment.BACKUP = "dump";
  boot.tmp.cleanOnBoot = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.systemd-boot.enable = mkForce false;

  # ======================== DO NOT CHANGE THIS ========================
  system.stateVersion = "24.11";
  # ======================== DO NOT CHANGE THIS ========================
}
