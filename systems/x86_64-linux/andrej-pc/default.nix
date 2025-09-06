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
with lib.custom; {
  facter.reportPath = ./facter.json;
  custom = {
    programs.dolphin = enabled;
    presets.default = enabled;
    presets.wayland = enabled;
    presets.gaming = enabled;
    hardware = {
      nvidia = enabled;
      bluetooth = enabled;
      printing = enabled;
    };

    users = {
      kylekrein = {
        enable = true;
      };
      andrej = {
        enable = true;
      };
    };

    presets.disko = {
      ext4Swap = {
        enable = true;
        device = "/dev/sda";
        swapSize = 16;
      };
      ext4 = {
        enable = false;
        device = "/dev/sdb";
        mountpoint = "/home/andrej/SteamGames";
      };
    };
  };

  services.flatpak = enabled;
  security.pam.services.quickshell = {};

  services.xserver = {
    enable = true;
    displayManager.sddm.enable = true;
  };
  programs.hyprland.enable = true;

  networking.firewall.allowedTCPPorts = [22 25565];
  networking.firewall.allowedUDPPorts = [22 25565];

  services.scx.enable = true; # by default uses scx_rustland scheduler
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_cachyos;

  security.polkit.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  programs.kdeconnect.enable = true;
  programs.kdeconnect.package = lib.mkDefault pkgs.kdePackages.kdeconnect-kde;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/etc/nixos-config";
  };

  environment.systemPackages = with pkgs; [
    libreoffice
    fzf
    killall
    eza
    fd
    gparted
    exfatprogs
    lazygit
    fastfetch
    telegram-desktop
    vlc
    wl-clipboard
    git
    git-credential-manager
    egl-wayland
    btop
    obs-studio
    blender
    vscodium-fhs
    discord
    solaar
    element-desktop

    prismlauncher
    mcpelauncher-ui-qt
    jdk
    teams-for-linux
  ];
  hardware.nvidia.open = lib.mkForce false;
  #hardware.nvidia.package = lib.mkForce config.boot.kernelPackages.nvidiaPackages.latest;
  systemd.network.wait-online.enable = lib.mkForce false;

  services.udisks2.enable = true;

  services.zerotierone = {
    enable = true;
    joinNetworks = [
      "a09acf0233dccb4a"
      "1d71939404962783"
      "41d49af6c260338d"
    ];
  };

  # ======================== DO NOT CHANGE THIS ========================
  system.stateVersion = "24.11";
  # ======================== DO NOT CHANGE THIS ========================
}
