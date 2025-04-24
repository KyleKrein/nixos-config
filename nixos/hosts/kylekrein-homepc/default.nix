{
  options,
  config,
  pkgs,
  unstable-pkgs,
  lib,
  hwconfig,
  inputs,
  ...
}: {
  imports = [
    ../../hardware/nvidia

    ../../modules/hyprland

    ../../modules/libvirt

    ../../users/kylekrein
    (import ../../modules/libvirt/user.nix {username = "kylekrein";})

    ../../users/dima
    (import ../../modules/libvirt/user.nix {username = "dima";})


    ../../users/tania
  ];
  sops.secrets."ssh_keys/${hwconfig.hostname}" = {};
  environment.systemPackages = with pkgs; [
    blender
    ladybird
    
    android-tools
    android-studio
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
    loadModels = [ "qwq" ];
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
  #services.open-webui.package = unstable-pkgs.open-webui;
  services.open-webui.openFirewall = false;
  services.open-webui.host = "0.0.0.0";
  services.open-webui.stateDir = "/persist/open-webui";
  systemd.services.open-webui.serviceConfig.User = "ollama";
  systemd.services.open-webui.serviceConfig.Group = "ollama";
  systemd.services.open-webui.serviceConfig.DynamicUser = lib.mkForce false;

  #Chat host
  networking.firewall.allowedTCPPorts = [ 80 443 22 8448 9993 8081] ++ [ config.services.zerotierone.port ];
  networking.firewall.allowedUDPPorts = [config.services.zerotierone.port];
#  users.users.nginx.extraGroups = [ "acme" ];
  services.hypridle.enable = lib.mkForce false;
  programs.hyprlock.enable = lib.mkForce false;

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
      #forceSSL = true;
      #useACMEHost = "kylekrein.com";
      #acmeRoot = "/var/lib/acme/challenges-kylekrein";
    }; in {
      "chat.kylekrein.com" = (SSL // {
        locations."/" = {
          proxyPass = "http://localhost:8080/";
          proxyWebsockets = true;
        };
      });
    };

  systemd.network.wait-online.enable = lib.mkForce false;
}
