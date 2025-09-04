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
  cfg = config.${namespace}.windowManagers.niri;
in {
  options.${namespace}.windowManagers.niri = with types; {
    enable = mkBoolOpt false "Enable Niri as your window manager";
  };

  config = mkIf cfg.enable {
    ${namespace} = {
      programs.dolphin.enable = mkDefault true;
    };
    security.pam.services.quickshell = {};
    programs.niri = {
      enable = true;
      package = pkgs.niri-unstable;
    };
    niri-flake.cache.enable = true;
    environment.systemPackages = with pkgs; [
      wl-clipboard
      wayland-utils
      libsecret
      gamescope
      xwayland-satellite-unstable
    ];

    #greeter
    services.xserver.displayManager.gdm.enable = true;
  };
}
