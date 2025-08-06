{
  lib,
  pkgs,
  inputs,
  ...
}:
with lib.custom; {
  custom.presets.default = enabled;
  custom.gpg = enabled;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Enable common container config files in /etc/containers
  virtualisation.containers.enable = true;
  virtualisation = {
    docker.enable = true;
  };
  users.extraGroups.docker.members = ["nixos"];
  environment.systemPackages = with pkgs; [
    inputs.emacs-kylekrein.packages.${pkgs.system}.with-lsps-native
    nix-output-monitor
    eza
    fd
    tealdeer
    docker-compose
    fzf
    lazygit
    fastfetch
    wl-clipboard
    git
    #git-credential-manager
    egl-wayland
    xclip
    btop
    comma

    csharp-ls
  ];
  wsl = {
    enable = true;
    defaultUser = "nixos";
    useWindowsDriver = true;
  };
  programs.nh = {
    flake = lib.mkForce "/home/nixos/nixos-config";
  };
  services.ollama = {
    enable = true;
    loadModels = ["llama3.1" "qwen2.5-coder:7b"];
    acceleration = "cuda";
    user = "ollama";
    group = "ollama";
  };
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    font-awesome
    nerd-fonts.symbols-only
    hack-font
    # microsoft fonts:
    corefonts
    vistafonts
  ];
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XDG_RUNTIME_DIR = "/mnt/wslg/runtime-dir"; #sometimes gui apps stop working in wsl. This option makes GUI apps load much slower but at least they work https://github.com/microsoft/wslg/issues/1303#issuecomment-2764300164
    EDITOR = "emacsclient -c";
  };

  hardware = {
    graphics = {
      enable = true;
    };
  };

  security.polkit.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  programs.bash = {
    shellAliases = {
      ls = "${pkgs.eza}/bin/eza --icons=always";
    };
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [22];
  networking.firewall.allowedUDPPorts = [22];
  # Or disable the firewall altogether.
  #networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      substituters = [
        "https://hyprland.cachix.org"
        "https://nix-gaming.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };
}
