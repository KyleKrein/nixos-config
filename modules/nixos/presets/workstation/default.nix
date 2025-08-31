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
with lib.${namespace}; let
  cfg = config.${namespace}.presets.workstation;
in {
  options.${namespace}.presets.workstation = with types; {
    enable = mkBoolOpt false "Enable workstation preset";
  };

  config = mkIf cfg.enable {
    ${namespace} = {
      presets.default = enabled;
      presets.wayland = enabled;
      hardware.printing = enabled;
      hardware.bluetooth = enabled;
      #programs.fastfetch = {
      #  enable = true;
      #  firstNixOSInstall = 1729112485;
      #};
      gpg = enabled;
      services.syncthing = {
        enable = true;
        user = "kylekrein";
      };
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    networking.networkmanager.enable = true;
    services.udisks2.enable = true;

    environment.systemPackages = with pkgs;
    with pkgs.${namespace}; [
      rnote
      libreoffice
      root-files
      gparted
      qdirstat
      exfatprogs
      kitty
      tealdeer
      telegram-desktop
      vlc
      git-credential-manager
      kitty-themes
      qpwgraph
      solaar
      pdfarranger
      densify
      gimp3

      #kde
      kdePackages.gwenview
      kdePackages.ark
      shotwell

      deploy-rs
      custom.deploy-rs-online
    ];
    programs.kdeconnect.enable = true;
    programs.kdeconnect.package = lib.mkDefault pkgs.kdePackages.kdeconnect-kde;
    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      font-awesome
      nerd-fonts.symbols-only
      hack-font
      noto-fonts-emoji
      # microsoft fonts:
      #corefonts
      #vistafonts
    ];
    environment.sessionVariables = {
      MANPAGER = "emacsclient -c";
      EDITOR = "emacsclient -c";
    };
    hardware = {
      logitech.wireless.enable = true;
    };

    security.polkit.enable = true;
    services.flatpak = enabled;

    #programs.thunar = {
    #	enable = true;
    #	plugins = with pkgs.xfce; [
    #		thunar-archive-plugin
    #		thunar-volman
    #	];
    # };
    #programs.xfconf.enable = true; # so thunar can save config
    #services.gvfs.enable = true; # Mount, trash, and other functionalities
    #services.tumbler.enable = true; # Thumbnail support for images

    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };
}
