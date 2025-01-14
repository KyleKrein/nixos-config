# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  lib,
  pkgs,
  hwconfig,
  first-nixos-install,
  inputs,
  ...
}: {
  imports =
    [
      inputs.sops-nix.nixosModules.sops
      inputs.stylix.nixosModules.stylix
      inputs.nixos-facter-modules.nixosModules.facter
      inputs.home-manager.nixosModules.default
      inputs.disko.nixosModules.default

      ./modules/firefox
      ./modules/flatpak
      ./modules/steam
      ./modules/ly
      ./modules/sddm
      ./modules/services/autoupgrade
      ./modules/sops
      ./modules/emacs
      ./hosts/${hwconfig.hostname}
    ]
    ++ lib.optional (hwconfig.useImpermanence) ./modules/impermanence;
  facter.reportPath = ./hosts/${hwconfig.hostname}/facter.json;
  kylekrein.services.autoUpgrade = {
    enable = true;
    pushUpdates =
      if hwconfig.hostname == "kylekrein-homepc"
      then true
      else false;
    configDir = "/etc/nixos-config";
    user = "root";
  };

  boot = {
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

    plymouth = {
      enable = true;
    };
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables =
        if hwconfig.hostname != "kylekrein-mac"
        then true
        else false;
    };
    # Enable "Silent Boot"
    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
    # Hide the OS choice for bootloaders.
    # It's still possible to open the bootloader list by pressing any key
    # It will just not appear on screen unless a key is pressed
    loader.timeout = 0;
  };

  networking.hostName = hwconfig.hostname;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  #flatpak
  kk.services.flatpak.enable = hwconfig.system != "aarch64-linux";
  services.flatpak.packages = [
    "com.super_productivity.SuperProductivity" # only x86_64-linux
    "net.cozic.joplin_desktop"
  ];

  # Enable networking
  networking.networkmanager.enable = true;

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

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us,ru";
    variant = "";
    options = "grp:caps_toggle";
  };
  console.keyMap = "us";

  services.udisks2.enable = true;

  users = {
    mutableUsers = false;
    users = {
      root = {
        # disable root login here, and also when installing nix by running nixos-install --no-root-passwd
        # https://discourse.nixos.org/t/how-to-disable-root-user-account-in-configuration-nix/13235/3
        hashedPassword = "!"; # disable root logins, nothing hashes to !
      };
    };
  };

  qt = {
    enable = true;
    platformTheme = "qt5ct";
    style = "kvantum";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    kdenlive
    system-config-printer
    libreoffice
    helvum
    killall
    nix-output-monitor
    eza
    fd
    (pkgs.writeShellScriptBin "root-files" ''
      ${pkgs.fd}/bin/fd --one-file-system --base-directory / --type f --hidden --exclude "{tmp,etc/passwd}"
    '') #https://www.reddit.com/r/NixOS/comments/1d1apm0/comment/l5tgbwz/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
    gparted
    exfatprogs
    kitty
    yazi
    tealdeer
    fzf
    lazygit
    kdePackages.qtwayland
    #libsForQt5.qt5.qtwayland
    #libsForQt5.qt5.qtsvg
    kdePackages.qtsvg
    #kio-fuse #to mount remote filesystems via FUSE
    #libsForQt5.kio-extras #extra protocols support (sftp, fish and more)
    kdePackages.kio-fuse #to mount remote filesystems via FUSE
    kdePackages.kio-extras #extra protocols support (sftp, fish and more)
    fastfetch
    firefox
    telegram-desktop
    vlc
    wl-clipboard
    git
    git-credential-manager
    egl-wayland
    kitty-themes
    btop
    solaar

    #kde
    kdePackages.kate
    kdePackages.gwenview
    kdePackages.breeze-icons
    kdePackages.breeze
    kdePackages.ark
    kdePackages.qtstyleplugin-kvantum
    kdePackages.okular
    kdePackages.kcalc
    polkit-kde-agent
    kdePackages.kdeconnect-kde
    kdePackages.kdesdk-thumbnailers
    kdePackages.kdegraphics-thumbnailers
    catppuccin-kvantum
    kdePackages.kservice
    kdePackages.kdbusaddons
    kdePackages.kfilemetadata
    kdePackages.kconfig
    kdePackages.kcoreaddons
    kdePackages.kcrash
    kdePackages.kguiaddons
    kdePackages.ki18n
    kdePackages.kitemviews
    kdePackages.kwidgetsaddons
    kdePackages.kwindowsystem
    shared-mime-info
    #kdePackages.plasma-workspace

    #kde support tools
    libsForQt5.qt5ct
    qt6ct
    kdePackages.kimageformats
    kdePackages.dolphin
    kdePackages.dolphin-plugins
    # user packages
    obs-studio
    vesktop
    vscode-fhs
    inputs.neovim.packages.${hwconfig.system}.default
  ];
  programs.kdeconnect.enable = true;
  programs.kdeconnect.package = lib.mkDefault pkgs.kdePackages.kdeconnect-kde;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/etc/nixos-config";
  };
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    font-awesome
    hack-font
    corefonts
    vistafonts
  ];
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MANPAGER = "nvim +Man!";
    EDITOR = "nvim";
  };
  kk.loginManagers.sddm.enable = true;

  hardware = {
    graphics = {
      enable = true;
    };
    logitech.wireless.enable = true;
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Experimental = true;
        };
      };
    };
  };
  services.blueman.enable = true;

  security.polkit.enable = true;

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

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit pkgs;
      inherit hwconfig;
      inherit first-nixos-install;
      inherit inputs;
    };
  };
  stylix = {
    enable = true;
    image = "${./modules/hyprland/wallpaper.jpg}";
    autoEnable = true;
    opacity = {
      desktop = 0.5;
    };
    targets = {
      gtk.enable = true;
      plymouth = {
        enable = true;
        #logo = ./fastfetch/nixos.png;
        logoAnimated = false;
      };
    };
    fonts = {
      sizes = {
        applications = 14;
        desktop = 12;
        popups = 12;
        terminal = 16;
      };
    };
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
  };

  programs.bash = {
    shellAliases = {
      ls = "${pkgs.eza}/bin/eza --icons=always";
    };
  };

  #printing
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  #services.flatpak.enable = true;
  #services.flatpak.packages = [
  #	"flathub:app/org.kde.dolphin//stable"
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  kk.steam.enable = hwconfig.system == "x86_64-linux";

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    # require public key authentication for better security
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = "no";
    extraConfig = "HostKey ${config.sops.secrets."ssh_keys/${hwconfig.hostname}".path}";
  };

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
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
      substituters = ["https://hyprland.cachix.org" "https://nix-gaming.cachix.org"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="];
    };
  };
}
