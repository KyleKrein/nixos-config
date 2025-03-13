{
  pkgs,
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

    ../../users/tania
  ];

  sops.secrets."ssh_keys/${hwconfig.hostname}" = {};
  environment.systemPackages = with pkgs; [
    blender
    ladybird
    #inputs.nix-gaming.packages.${pkgs.system}.star-citizen
  ];
  #LLMs
  services.ollama = {
    enable = true;
    loadModels = [ "deepseek-r1:32b" "deepseek-r1:8b"];
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
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  security.acme = {
    acceptTerms = true;
    defaults.email = "alex.lebedev2003@icloud.com";
  };
  services.nginx.enable = false;
  services.nginx = {
    # Use recommended settings
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
  };
  services.nginx.virtualHosts = let
    SSL = {
      enableACME = true;
      forceSSL = true;
    }; in {
      "chat.kylekrein.com" = (SSL // {
        locations."/" = {
          proxyPass = "http://127.0.0.1:8080/";
          proxyWebsockets = true;
        };
      });
    };
  
  systemd.network.wait-online.enable = lib.mkForce false;
}
