{
  lib,
  pkgs,
  namespace,
  config,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.presets.default;
in {
  options.${namespace}.presets.default = with types; {
    enable = mkBoolOpt false "Enable preset with all the default settings - locale, time, etc";
  };

  config = mkIf cfg.enable {
    zramSwap = {
      enable = true; # Hopefully? helps with freezing when using swap
    };
    services.fwupd.enable = true; #fwupdmgr update
    boot = {
      kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
      loader = {
        systemd-boot.enable = !config.${namespace}.hardware.secureBoot.enable;
        efi.canTouchEfiVariables = !config.${namespace}.hardware.asahi.enable;
      };
      # Hide the OS choice for bootloaders.
      # It's still possible to open the bootloader list by pressing any key
      # It will just not appear on screen unless a key is pressed
      loader.timeout = 0;
    };
    # Set your time zone.
    time.timeZone = "Europe/Berlin";

    # Select internationalisation properties.
    i18n.defaultLocale = "ru_RU.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "de_DE.UTF-8";
      LC_IDENTIFICATION = "de_DE.UTF-8";
      LC_MEASUREMENT = "de_DE.UTF-8";
      LC_MONETARY = "de_DE.UTF-8";
      LC_NAME = "de_DE.UTF-8";
      LC_NUMERIC = "de_DE.UTF-8";
      LC_PAPER = "de_DE.UTF-8";
      LC_TELEPHONE = "de_DE.UTF-8";
      LC_TIME = "de_DE.UTF-8";
    };
    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
      flake = "/etc/nixos-config";
    };
    environment.systemPackages = with pkgs; [
      nix-output-monitor
      fzf
      lazygit
      git
      btop
      comma
      snowfallorg.flake
    ];
    programs.bash = {
      shellAliases = {
        ls = "${pkgs.eza}/bin/eza --icons=always";
      };
    };
    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "eu,ru";
      variant = "";
      options = "grp:caps_toggle";
    };
    console.keyMap = "us";
    nix = {
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        auto-optimise-store = true;
        substituters = [
          "https://nix-gaming.cachix.org"
          "https://nix-community.cachix.org"
        ];
        trusted-public-keys = [
          "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };
    };
  };
}
