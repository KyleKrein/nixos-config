{
  options,
  config,
  pkgs,
  lib,
  hwconfig,
  inputs,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.sops
    inputs.stylix.nixosModules.stylix
    inputs.nixos-facter-modules.nixosModules.facter
    inputs.home-manager.nixosModules.default
    inputs.disko.nixosModules.default
    ../../modules/sops
    ../../modules/services/autoupgrade
    ./conduwuit.nix

    ../../users/kylekrein
    ./hardware.nix
    ./networking.nix
  ];
  #options.services.conduwuit.settings.global.database_path = lib.mkOption { apply = old: "/persist/conduwuit/";};
  config = {
    home-manager.users = lib.mkForce {};
    stylix.image = ../../modules/hyprland/wallpaper.jpg;
    boot.tmp.cleanOnBoot = true;
    boot.loader.grub.enable = true;
    boot.loader.grub.device = "/dev/sda";
    networking.hostName = hwconfig.hostname;
    users = {
      mutableUsers = false;
      users = {
        root = {
          # disable root login here, and also when installing nix by running nixos-install --no-root-passwd
          # https://discourse.nixos.org/t/how-to-disable-root-user-account-in-configuration-nix/13235/3
          hashedPassword = "!"; # disable root logins, nothing hashes to !
        };
      };
    };
    environment.systemPackages = with pkgs; [
      neovim
      git
    ];
    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
      flake = "/etc/nixos-config";
    };
    services.openssh = {
      enable = true;
      # require public key authentication for better security
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
      settings.PermitRootLogin = "no";
    };

    zramSwap = {
      enable = true; # Hopefully? helps with freezing when using swap
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

    kk.services.conduwuit = {
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
          registration_token = ""; #nix shell nixpkgs#openssl -c openssl rand -base64 48 | tr -d '/+' | cut -c1-64
          allow_federation = true;
          allow_encryption = true;

          allow_local_presence = true;
          require_auth_for_profile_requests = true;
        };
      };
      extraEnvironment = {
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
    system.stateVersion = "24.11";
    nix = {
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        auto-optimise-store = true;
        substituters = [
          "https://hyprland.cachix.org"
          "https://nix-gaming.cachix.org"
          "https://nix-community.cachix.org"
        ];
        trusted-public-keys = [
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
          "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };
    };
  };
}
