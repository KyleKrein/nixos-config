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
    "${inputs.nixpkgs-unstable}/nixos/modules/services/matrix/conduwuit.nix"
    ../../hardware/nvidia

    ../../modules/hyprland

    ../../modules/libvirt

    ../../users/kylekrein
    (import ../../modules/libvirt/user.nix {username = "kylekrein";})

    ../../users/dima
    (import ../../modules/libvirt/user.nix {username = "dima";})


    ../../users/tania
  ];
options.services.conduwuit.settings.global.database_path = lib.mkOption { apply = old: "/persist/conduwuit/";};
config = {
  sops.secrets."ssh_keys/${hwconfig.hostname}" = {};
  environment.systemPackages = with pkgs; [
    blender
    ladybird
    #inputs.nix-gaming.packages.${pkgs.system}.star-citizen
  ];

  zramSwap = {
    enable = true; # Hopefully? helps with freezing when using swap
  };
  services.zerotierone = {
    enable = true;
    port = 9994;
    joinNetworks = [
      "A84AC5C10AD269CA"
      "db64858fed285e0f"
    ];
  };
  #LLMs
  services.ollama = {
    enable = true;
    loadModels = [ "deepseek-r1:32b" "qwq" "gemma3:27b"];
    acceleration = "cuda";
    home = "/persist/ollama";
    user = "ollama";
    group = "ollama";
  };
  services.llama-cpp = {
    enable = false;
    model = "/home/kylekrein/Downloads/ds/DeepSeek-R1-GGUF/DeepSeek-R1-UD-IQ1_S/DeepSeek-R1-UD-IQ1_S-00001-of-00003.gguf";
    port = 10005;
    extraFlags = [
      "--ctx-size 1024" #context size
      "--n-gpu-layers 0"
    ];
  };

  services.open-webui.enable = true;
  services.open-webui.openFirewall = false;
  services.open-webui.host = "0.0.0.0";
  services.open-webui.stateDir = "/persist/open-webui";
  systemd.services.open-webui.serviceConfig.User = "ollama";
  systemd.services.open-webui.serviceConfig.Group = "ollama";
  systemd.services.open-webui.serviceConfig.DynamicUser = lib.mkForce false;

  #Chat host
  networking.firewall.allowedTCPPorts = [ 80 443 22 8448 9993 ] ++ [ config.services.zerotierone.port ];
  networking.firewall.allowedUDPPorts = [config.services.zerotierone.port];
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
	    "chat.kylekrein.com"
	  ];
        };
    };
  };
#  users.users.nginx.extraGroups = [ "acme" ];
  services.hypridle.enable = lib.mkForce false;
  programs.hyprlock.enable = lib.mkForce false;
  sops.secrets."services/conduwuit" = {neededForUsers = true;};
  
  services.conduwuit = {
    enable = false;
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
      CONDUWUIT_REGISTRATION_TOKEN = "";
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

  #services.nginx.enable = true;
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
      "chat.kylekrein.com" = (SSL // {
        locations."/" = {
          proxyPass = "http://localhost:8080/";
          proxyWebsockets = true;
        };
      });
      "matrix.kylekrein.com" = (SSL // {
	listen = [{port = 443;  addr="0.0.0.0"; ssl=true;} {port = 8448;  addr="0.0.0.0"; ssl=true;}];
        locations."/" = {
          proxyPass = "http://localhost:6167";
          proxyWebsockets = true;
        };
      });
    };

  systemd.network.wait-online.enable = lib.mkForce false;
};
}
