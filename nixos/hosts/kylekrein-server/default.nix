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
 "${inputs.nixpkgs-unstable}/nixos/modules/services/matrix/conduwuit.nix"

    ../../users/kylekrein
    ./hardware.nix
    ./networking.nix
  ];
options.services.conduwuit.settings.global.database_path = lib.mkOption { apply = old: "/persist/conduwuit/";};
config = {
  home-manager.users = lib.mkForce {};
  stylix.image = ../../modules/hyprland/wallpaper.jpg;
  #sops.secrets."ssh_keys/${hwconfig.hostname}" = {};
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
            #extraConfig = "HostKey ${config.sops.secrets."ssh_keys/${hwconfig.hostname}".path}";
          };

  zramSwap = {
    enable = true; # Hopefully? helps with freezing when using swap
  };
  #Chat host
  networking.firewall.allowedTCPPorts = [ 80 443 22 8448 ];
  security.acme = {
    acceptTerms = true;
    defaults.email = "alex.lebedev2003@icloud.com";
    certs = {
        "kylekrein.com" = {
            webroot = "/var/lib/acme/challenges-kylekrein";
            email = "alex.lebedev2003@icloud.com";
            group = "nginx";
	  extraDomainNames = [
	    "matrix.kylekrein.com"
	    #"chat.kylekrein.com"
	  ];
        };
    };
  };
  users.users.nginx.extraGroups = [ "acme" ];
  sops.secrets."services/conduwuit" = {neededForUsers = true;};
  
  services.conduwuit = {
    enable = true;
    settings = {
      global = {
	server_name = "kylekrein.com";
	port = [ 6167 ];
	trusted_servers = [ "matrix.org" ];
	allow_registration = true;
	allow_federation = true;
	allow_encryption = true;
      };
    };
    extraEnvironment = {
      CONDUWUIT_REGISTRATION_TOKEN = "IActuallyLoveNixOSItIsFarBetterThanArch";
      #CONDUWUIT_REGISTRATION_TOKEN_FILE = ''"${config.sops.secrets."services/conduwuit".path}"'';
      CONDUWUIT_NEW_USER_DISPLAYNAME_SUFFIX = "🐝";
      CONDUWUIT_REQUIRE_AUTH_FOR_PROFILE_REQUESTS = "true";
      CONDUWUIT_ALLOW_LOCAL_PRESENCE = "true";
    };
  };
  systemd.services.conduwuit.serviceConfig = {
    DynamicUser = lib.mkForce false;
    StateDirectory = lib.mkForce "/persist/conduwuit";
    RuntimeDirectory = lib.mkForce "/persist/conduwuit/runtime";
  };

  services.nginx.enable = true;
  services.nginx = {
    # Use recommended settings
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    clientMaxBodySize = "20000000";
  };
  services.nginx.virtualHosts = let
    SSL = {
      #enableACME = true;
      forceSSL = true;
      useACMEHost = "kylekrein.com";
      acmeRoot = "/var/lib/acme/challenges-kylekrein";
    }; in {
      "kylekrein.com" = (SSL // {
	listen = [{port = 443;  addr="0.0.0.0"; ssl=true;} {port = 8448;  addr="0.0.0.0"; ssl=true;}];
        locations."/" = {
          proxyPass = "http://localhost:6167";
          proxyWebsockets = true;
        };
      });
      #"chat.kylekrein.com" = (SSL // {
      #  locations."/" = {
      #    proxyPass = "http://localhost:8080/";
      #    proxyWebsockets = true;
      #  };
      #});
      "matrix.kylekrein.com" = (SSL // {
	listen = [{port = 443;  addr="0.0.0.0"; ssl=true;} {port = 8448;  addr="0.0.0.0"; ssl=true;}];
        locations."/" = {
          proxyPass = "http://localhost:6167";
          proxyWebsockets = true;
        };
      });
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
