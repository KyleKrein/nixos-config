{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.kk.loginManagers.ly;
in {
  options.kk.loginManagers.ly = {
    enable = lib.mkEnableOption "Enable ly as login manager";
  };
  config = lib.mkIf cfg.enable {
    services.xserver.enable = true;
    services.displayManager.ly.enable = true;
  };
}
