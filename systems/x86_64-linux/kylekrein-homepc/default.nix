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
}:
with lib;
with lib.${namespace}; {
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
  custom.loginManagers.sddm = enabled;
  custom.services.ai = {
    enable = true;
    models = ["qwq" "llama3.1" "qwen2.5-coder:7b" "gpt-oss:20b" "gpt-oss:120b"];
  };

  custom.users = {
    kylekrein = enabled;
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
