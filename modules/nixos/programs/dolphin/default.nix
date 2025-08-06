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
  cfg = config.${namespace}.programs.dolphin;
in {
  options.${namespace}.programs.dolphin = with types; {
    enable = mkBoolOpt false "Enable dolphin on non Kde environments";
  };

  config =
    mkIf cfg.enable {
      environment.systemPackages = with pkgs; [
    kdePackages.qtwayland
    kdePackages.qtsvg
    kdePackages.kio-fuse #to mount remote filesystems via FUSE
    kdePackages.kio-extras #extra protocols support (sftp, fish and more)
    kdePackages.kio-admin
    libheif #https://github.com/NixOS/nixpkgs/issues/164021
    libheif.out

    #kde
    kdePackages.breeze-icons
    kdePackages.breeze
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

    #kde support tools
    #libsForQt5.qt5ct
    #qt6ct
    kdePackages.kimageformats
    kdePackages.dolphin
    kdePackages.dolphin-plugins
  ];
  xdg = {
    menus.enable = true;
    mime.enable = true;
  };

  #https://discourse.nixos.org/t/dolphin-does-not-have-mime-associations/48985/3
  # This fixes the unpopulated MIME menus
  environment.etc."/xdg/menus/plasma-applications.menu".text = builtins.readFile "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";
  environment.etc."/xdg/menus/applications.menu".text = builtins.readFile "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";
  #environment.pathsToLink = [
  #	"share/thumbnailers"
  #];
    };
}
