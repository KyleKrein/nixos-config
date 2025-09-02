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
  niri-config = {
    programs.niri = {
      settings = {
        #input.power-key-handling.enable = true;
        spawn-at-startup = [
          {
            command = [
              "${lib.getExe pkgs.brightnessctl}"
              "-s 20%"
            ];
          }
        ];
      };
    };
  };
in
  with lib;
  with lib.custom; {
    facter.reportPath = ./facter.json;
    systemd.network.wait-online.enable = lib.mkForce false; #facter

    custom.hardware.hibernation = {
      enable = true;
      swapFileOffset = 533760;
    };
    custom.presets.disko.impermanenceBtrfsLuks = {
      enable = true;
      swapSize = 64;
    };
    custom.hardware.framework12 = enabled;
    custom.hardware.secureBoot = enabled;
    custom.hardware.tablet.inputDevice = "/dev/input/by-path/platform-gpio-keys.9.auto-event";
    custom.impermanence = enabled;
    custom.presets.workstation = enabled;
    custom.presets.gaming = enabled;
    custom.windowManagers.niri = enabled;
    custom.loginManagers.sddm = enabled;
    custom.services.ai = {
      enable = true;
      models = ["qwq" "llama3.1" "qwen2.5-coder:7b" "gpt-oss:20b"];
    };
    custom.users.kylekrein = {
      enable = true;
      config = niri-config;
    };
    environment.systemPackages = with pkgs; [
      blender
      video-downloader
    ];
    services.power-profiles-daemon.enable = true;
    services.tlp.enable = false;
    #Chat host
    networking.firewall.allowedTCPPorts = [80 443 22 8448 9993 8081];

    # ======================== DO NOT CHANGE THIS ========================
    system.stateVersion = "25.05";
    # ======================== DO NOT CHANGE THIS ========================
  }
