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

    #inputs.nix-gaming.packages.${pkgs.system}.star-citizen
  ];
  #LLMs
  services.ollama = {
    enable = true;
    loadModels = [ "deepseek-r1:32b" ];
    acceleration = "cuda";
    home = "/persist/ollama";
    user = "ollama";
    group = "ollama";
  };
  services.open-webui.enable = true;
  services.open-webui.openFirewall = true;
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
  services.nginx.enable = true;
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
