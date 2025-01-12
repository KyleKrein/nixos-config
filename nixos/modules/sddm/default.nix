{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.kk.loginManagers.sddm;
in {
  options.kk.loginManagers.sddm = {
    enable = lib.mkEnableOption "Enable sddm as login manager";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      (catppuccin-sddm.override {
        flavor = "mocha";
        #	font = "";
        fontSize = "16";
        #background;
        loginBackground = false;
      })
    ];
    services.xserver.enable = true;
    services.displayManager.sddm = {
      enable = true;
      theme = "catppuccin-mocha";
      package = pkgs.kdePackages.sddm;
      wayland.enable = false;
    };
  };
}
