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
#options.services.conduwuit.settings.global.database_path = lib.mkOption { apply = old: "/persist/conduwuit/";};
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
  networking.firewall.allowedTCPPorts = [ 80 443 22 8448 
#3478 5349
];
 # networking.firewall.allowedUDPPortRanges = with config.services.coturn; [ {
  #    from = min-port;
   #   to = max-port;
    #} ];
  #networking.firewall.allowedUDPPorts = [ 3478 5349 ];
  sops.secrets."services/conduwuit" = {mode = "0755";};
  
  services.conduwuit = {
    enable = true;
    #user = "turnserver";
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
      CONDUWUIT_REGISTRATION_TOKEN = "TIebWOivZIx7oCxiX9FgMlxF8s6sTI1ppStDy3U3Ypm0fEmiJgOD8ppO1X6"; #nix shell nixpkgs#openssl -c openssl rand -base64 48 | tr -d '/+' | cut -c1-64
      #CONDUWUIT_REGISTRATION_TOKEN_FILE = ''"${config.sops.secrets."services/conduwuit".path}"'';
      CONDUWUIT_NEW_USER_DISPLAYNAME_SUFFIX = "🐝";
      CONDUWUIT_REQUIRE_AUTH_FOR_PROFILE_REQUESTS = "true";
      CONDUWUIT_ALLOW_LOCAL_PRESENCE = "true";
      CONDUWUIT_WELL_KNOWN__SERVER = "matrix.kylekrein.com:443";  
      CONDUWUIT_WELL_KNOWN__CLIENT = "https://matrix.kylekrein.com";
      #CONDUWUIT_TURN_URIS = "turn:turn.kylekrein.com:3478?transport=udp";
      #CONDUWUIT_TURN_SECRET = "true";
      #CONDUWUIT_TURN_SECRET_FILE = "\"${config.sops.secrets."services/conduwuit".path}\"";
    };
  };
  services.coturn = rec {
    enable = false;
    no-cli = true;
    no-tcp-relay = true;
    min-port = 49000;
    max-port = 50000;
    use-auth-secret = true;
    static-auth-secret-file = config.sops.secrets."services/conduwuit".path;
    realm = "turn.kylekrein.com";
    #cert = "${config.security.acme.certs.${realm}.directory}/full.pem";
    #pkey = "${config.security.acme.certs.${realm}.directory}/key.pem";
  };
  services.caddy = {
  enable = true;
  virtualHosts."kylekrein.com:8448".extraConfig = ''
    reverse_proxy http://localhost:6167
  '';
  virtualHosts."matrix.kylekrein.com, matrix.kylekrein.com:8448".extraConfig = ''
    reverse_proxy http://localhost:6167
  '';
  #virtualHosts."turn.kylekrein.com:3478".extraConfig = ''
  #reverse_proxy http://localhost:3478
  #'';
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
