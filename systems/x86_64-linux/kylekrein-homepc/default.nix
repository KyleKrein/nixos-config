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
}: let
  niri-outputs = {
    programs.niri.settings.outputs = {
      "DP-1" = {
        scale = 1.6;
        position.x = 1600;
        position.y = 0;
      };
      "DP-3" = {
        scale = 1.6;
        position.x = 0;
        position.y = 0;
      };
    };
  };
in
  with lib;
  with lib.${namespace}; {
    facter.reportPath = ./facter.json;
    systemd.network.wait-online.enable = lib.mkForce false; #facter

    custom.hardware.nvidia = enabled;
    boot.kernelPackages = lib.mkForce pkgs.linuxPackages_cachyos;
    services.scx.enable = true; # by default uses scx_rustland scheduler
    custom.impermanence = enabled;
    custom.presets.workstation = enabled;
    custom.presets.gaming = enabled;
    custom.presets.disko.impermanenceBtrfs = {
      enable = true;
      device = "/dev/nvme0n1";
      swapSize = 32;
    };
    custom.windowManagers.niri = enabled;
    custom.services.ai = {
      enable = true;
      models = ["qwq" "llama3.1" "qwen2.5-coder:7b" "gpt-oss:20b" "gpt-oss:120b"];
    };

    custom.users = {
      kylekrein = {
        enable = true;
        config = niri-outputs;
      };
      tania = {
        inherit (config.custom.users.kylekrein) enable config;
      };
    };

    environment.systemPackages = with pkgs; [
      blender
    ];

    services.zerotierone = {
      enable = true;
      port = 9994;
      joinNetworks = [
        "A84AC5C10AD269CA"
        "db64858fed285e0f"
      ];
    };
    #Chat host
    networking.firewall.allowedTCPPorts = [80 443 22 8448 9993 8081] ++ [config.services.zerotierone.port];
    networking.firewall.allowedUDPPorts = [config.services.zerotierone.port];

    # ======================== DO NOT CHANGE THIS ========================
    system.stateVersion = "25.05";
    # ======================== DO NOT CHANGE THIS ========================
  }
