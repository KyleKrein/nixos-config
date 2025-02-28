{ ... }:
{
    services.xserver.enable = true;
    services.desktopManager.plasma6.enable = true;

    programs.dconf.enable = true;

    #stylix.targets.qt.platform = "qtct";
}
