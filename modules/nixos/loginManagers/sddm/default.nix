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
  cfg = config.${namespace}.loginManagers.sddm;
in {
  options.${namespace}.loginManagers.sddm = with types; {
    enable = mkBoolOpt false "Enable sddm as login manager";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      (catppuccin-sddm.override {
        flavor = "mocha";
        #	font = "";
        fontSize = "16";
        #background;
        loginBackground = false;
      })
      wvkbd
    ];
    services.xserver.enable = true;
    services.displayManager.sddm = {
      enable = true;
      theme = "catppuccin-mocha";
      package = mkDefault pkgs.kdePackages.sddm;
      wayland.enable = mkDefault config.${namespace}.presets.wayland.enable;
      settings = {
        General = {
          InputMethod = "wvkbd-mobintl"; # Enables optional virtual keyboard at login (SDDM). Useful for touchscreens or accessibility.
        };
      };
    };
  };
}
