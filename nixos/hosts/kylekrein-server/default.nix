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
3478 5349
];
  networking.firewall.allowedUDPPortRanges = with config.services.coturn; [ {
      from = min-port;
      to = max-port;
    } ];
  networking.firewall.allowedUDPPorts = [ 3478 5349 ];
  sops.secrets."services/conduwuit" = {mode = "0755";};
  
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
	port = [ 6167 ];
	trusted_servers = [ "matrix.org" ];
	allow_registration = true;
	registration_token = "8ptB9GHlPwglvllBksplhA9sBHfVFXpJC6uQawIvNiyfkt0owZywhyIWRTx"; #nix shell nixpkgs#openssl -c openssl rand -base64 48 | tr -d '/+' | cut -c1-64
	allow_federation = true;
	allow_encryption = true;

	allow_local_presence = true;
	require_auth_for_profile_requests = true;

	turn_secret = "GvCOQnutdoEi3DXH5ueFBPVGftwQmCLRWgrmuvjRpqcbwmjffwXe8iu7XMQ23z6m";#_file = config.sops.secrets."services/conduwuit".path;
	turn_uris = [ "turn:91.99.0.169?transport=udp" "turn:91.99.0.169?transport=tcp" ];
      };
    };
    extraEnvironment = {
    };
  };
  services.coturn = rec {
    enable = true;
    no-cli = true;
    no-tcp-relay = true;
    min-port = 49000;
    max-port = 50000;
    use-auth-secret = true;
    static-auth-secret = "GvCOQnutdoEi3DXH5ueFBPVGftwQmCLRWgrmuvjRpqcbwmjffwXe8iu7XMQ23z6m";#-file = config.sops.secrets."services/conduwuit".path;
    realm = "91.99.0.169";
    listening-ips = [ "91.99.0.169" ];
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
  virtualHosts."turn.kylekrein.com".extraConfig = ''
  reverse_proxy http://91.99.0.169:3478
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
