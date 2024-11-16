# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, stylix, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.default
      ./firefox.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  networking.hostName = "nixosbtw"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kylekrein = {
    isNormalUser = true;
    description = "Aleksandr Lebedev";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  qt = {
	enable = true;
	platformTheme = "qt5ct";
	style = "kvantum";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
     kitty
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
     waybar
     swaynotificationcenter
     libnotify
     swww
     vlc
     wofi
     wl-clipboard
     git
     git-credential-manager
     hyprpicker
     networkmanagerapplet
     egl-wayland
     kitty-themes
     btop
     hyprlock
     hypridle
     solaar
     pavucontrol
     brightnessctl
     satty
     grim
     slurp
     clipse
     libheif #https://github.com/NixOS/nixpkgs/issues/164021
     libheif.out

     #kde
     kdePackages.systemsettings
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
  ];
  programs.kdeconnect.enable = true;
  programs.kdeconnect.package = pkgs.kdePackages.kdeconnect-kde;
  xdg = {
	menus.enable = true;
	mime.enable = true;
  };
  #https://discourse.nixos.org/t/dolphin-does-not-have-mime-associations/48985/3
  # This fixes the unpopulated MIME menus
  environment.etc."/xdg/menus/plasma-applications.menu".text = builtins.readFile "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";
  #xdg.portal = {
  #  enable = true;
  #  config = {
  #    hyprland = {
  #      default = [
  #        "hyprland"
  #        "kde"
  #      ];
  #    };
  #  };
  #  configPackages = with pkgs; [
  #    xdg-desktop-portal-hyprland
  #    kdePackages.xdg-desktop-portal-kde
  #  ];
  #};
  environment.pathsToLink = [
	"share/thumbnailers"
  ];
  fonts.packages = with pkgs; [ 
  	(nerdfonts.override { fonts = [ "JetBrainsMono" ]; }) 
     	font-awesome
	hack-font
  ];
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  hardware = {
	graphics = {
		enable = true;
		extraPackages = with pkgs; [
			nvidia-vaapi-driver
		];
	};
	nvidia = {
		# https://nixos.wiki/wiki/Nvidia
		# Modesetting is required.
    		modesetting.enable = true;

    		# Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    		# Enable this if you have graphical corruption issues or application crashes after waking
    		# up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    		# of just the bare essentials.
   		powerManagement.enable = true;#false;

    		# Fine-grained power management. Turns off GPU when not in use.
    		# Experimental and only works on modern Nvidia GPUs (Turing or newer).
    		powerManagement.finegrained = false;

    		# Use the NVidia open source kernel module (not to be confused with the
    		# independent third-party "nouveau" open source driver).
    		# Support is limited to the Turing and later architectures. Full list of 
    		# supported GPUs is at: 
    		# https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    		# Only available from driver 515.43.04+
    		# Currently alpha-quality/buggy, so false is currently the recommended setting.
    		open = true;

    		# Enable the Nvidia settings menu,
		# accessible via `nvidia-settings`.
    		nvidiaSettings = true;

    		# Optionally, you may need to select the appropriate driver version for your specific GPU.
    		package = config.boot.kernelPackages.nvidiaPackages.stable;	
	};
		
	logitech.wireless.enable = true;
  };
  services.xserver.videoDrivers = [ "nvidia" ];

  security.polkit.enable = true;


  programs.steam = {
 	enable = true;
 	remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
 	dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  	localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

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
	extraSpecialArgs = {inherit pkgs; inherit inputs;};
	users = {
		"kylekrein" = import ./home.nix;
	};
  };
  stylix = {
  	enable = true;
  	image = ./hyprland/wallpaper.jpg;
	autoEnable = true;
	opacity = {
		desktop = 0.5;
	};
	targets = {
		gtk.enable = true;
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

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
  
  programs.hyprland = {
  	enable = true;
  	package = inputs.hyprland.packages."${pkgs.system}".hyprland;
  	xwayland.enable = true;
	systemd.setPath.enable = true;
  };
  services.hypridle.enable = true;

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
 # services.displayManager.sddm.wayland.enable = true;
  nix = {
     settings.experimental-features = ["nix-command" "flakes"];
  };
}
