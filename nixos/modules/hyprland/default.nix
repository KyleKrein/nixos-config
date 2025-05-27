{ pkgs, inputs, hwconfig, unstable-pkgs, ... }:
{
    environment.systemPackages = with pkgs; [
	#kando

	kdePackages.qtwayland
	#libsForQt5.qt5.qtwayland
	#libsForQt5.qt5.qtsvg
	kdePackages.qtsvg
	#kio-fuse #to mount remote filesystems via FUSE
	#libsForQt5.kio-extras #extra protocols support (sftp, fish and more)
	kdePackages.kio-fuse #to mount remote filesystems via FUSE
	kdePackages.kio-extras #extra protocols support (sftp, fish and more)
	kdePackages.kio-admin
	waybar
	swaynotificationcenter
	libnotify
	swww
	hyprpicker
	networkmanagerapplet
	hyprlock
	wlogout
	hypridle
  qpwgraph
  pwvucontrol
	brightnessctl
	unstable-pkgs.satty #fixes crash in 0.18.0
	grim
	slurp
	clipse
	libheif #https://github.com/NixOS/nixpkgs/issues/164021
	libheif.out
	
	#kde
	kdePackages.breeze-icons
	kdePackages.breeze
	kdePackages.polkit-kde-agent-1
	kdePackages.kdesdk-thumbnailers
	kdePackages.kdegraphics-thumbnailers
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
    ];

    programs.kdeconnect.enable = true;
    programs.kdeconnect.package = pkgs.kdePackages.kdeconnect-kde;
    programs.hyprlock.enable = true;

    xdg = {
	menus.enable = true;
	mime.enable = true;
    };
    xdg.portal = {
	enable = true;
	config = {
	    hyprland = {
		default = [
		"hyprland"
		"kde"
		];
	    };
	};
	configPackages = with pkgs; [
	    xdg-desktop-portal-hyprland
	    kdePackages.xdg-desktop-portal-kde
	];
    };

    #https://discourse.nixos.org/t/dolphin-does-not-have-mime-associations/48985/3
    # This fixes the unpopulated MIME menus
    environment.etc."/xdg/menus/plasma-applications.menu".text = builtins.readFile "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";
    environment.etc."/xdg/menus/applications.menu".text = builtins.readFile "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";
    #environment.pathsToLink = [
    #	"share/thumbnailers"
    #];

    programs.hyprland = {
	enable = true;
  	xwayland.enable = true;
	systemd.setPath.enable = true;
    };
    services.hypridle.enable = true;

   # qt = {
	#enable = true;
	#platformTheme = "qt5ct";
	#style = "kvantum";
   # };


}
