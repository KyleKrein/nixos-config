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
  unstable-pkgs,
  ...
}:
{
  programs.firefox.policies.Preferences."browser.startup.page" = lib.mkForce 1;

  imports = [
    inputs.sops-nix.nixosModules.sops
    inputs.stylix.nixosModules.stylix
    inputs.nixos-facter-modules.nixosModules.facter
    inputs.home-manager.nixosModules.default
    inputs.disko.nixosModules.default

    ../../modules/firefox
    ../../modules/flatpak
    ../../modules/steam
    ../../modules/ly
    ../../modules/sddm
    ../../modules/services/autoupgrade
    ../../modules/sops
    #../../modules/emacs
    ./default.nix
  ] ++ lib.optional (hwconfig.useImpermanence) ./modules/impermanence;
  facter.reportPath = ./facter.json;
  kylekrein.services.autoUpgrade = {
    enable = true;
    pushUpdates = false;
    configDir = "/etc/nixos-config";
    user = "root";
  };


  boot = {
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
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
  kk.services.flatpak.enable = true;
  services.flatpak.packages = [
    
  ];

  services.pipewire = {
    extraLv2Packages = [ pkgs.rnnoise-plugin ];
    configPackages = [
      (pkgs.writeTextDir "share/pipewire/pipewire.conf.d/20-rnnoise.conf" ''
        context.modules = [
        {   name = libpipewire-module-filter-chain
            args = {
                node.description = "Noise Canceling source"
                media.name = "Noise Canceling source"
                filter.graph = {
                    nodes = [
                        {
                            type = lv2
                            name = rnnoise
                            plugin = "https://github.com/werman/noise-suppression-for-voice#stereo"
                            label = noise_suppressor_stereo
                            control = {
                            }
                        }
                    ]
                }
                capture.props = {
                    node.name =  "capture.rnnoise_source"
                    node.passive = true
                }
                playback.props = {
                    node.name =  "rnnoise_source"
                    media.class = Audio/Source
                }
            }
        }
        ]
      '')
    ];
  };

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

  #qt = {
  #  enable = true;
  #  platformTheme = "qt5ct";
  #  style = "kvantum";
  #};

  # List packages installed in system profile. To search, run:
  # $ nix search wget
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
    unstable-pkgs.wasistlos

    prismlauncher
    unstable-pkgs.mcpelauncher-ui-qt
    jdk
    teams-for-linux
  ];
  programs.kdeconnect.enable = true;
  programs.kdeconnect.package = lib.mkDefault pkgs.kdePackages.kdeconnect-kde;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/etc/nixos-config";
  };
  fonts.packages = with unstable-pkgs; [ #TODO change to pkgs when 25.05 comes out
    nerd-fonts.jetbrains-mono
    font-awesome
    nerd-fonts.symbols-only
    hack-font
    # microsoft fonts:
    #corefonts
    #vistafonts
  ];
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    #MANPAGER = "emacsclient -c -a 'emacs' +Man!";
    #EDITOR = "emacsclient -c -a 'emacs'";
  };
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
      };
      stylix = {
        enable = false;
        image = "${../../modules/hyprland/wallpaper.jpg}";
        autoEnable = true;
        opacity = {
          desktop = 0.0;#0.5;
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

          kk.steam.enable = true;

          # List services that you want to enable:

          # Enable the OpenSSH daemon.
          services.openssh = {
            enable = true;
            # require public key authentication for better security
            settings.PasswordAuthentication = false;
            settings.KbdInteractiveAuthentication = false;
            settings.PermitRootLogin = "no";
            #extraConfig = "HostKey ${config.sops.secrets."ssh_keys/${hwconfig.hostname}".path}";
          };

          # Open ports in the firewall.
          networking.firewall.allowedTCPPorts = [ 22 ];
          networking.firewall.allowedUDPPorts = [ 22 ];
          # Or disable the firewall altogether.
          #networking.firewall.enable = false;

          # This value determines the NixOS release from which the default
          # settings for stateful data, like file locations and database versions
          # on your system were taken. It‘s perfectly fine and recommended to leave
          # this value at the release version of the first install of this system.
          # Before changing this value read the documentation for this option
          # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
          system.stateVersion = "24.11"; # Did you read the comment?

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
