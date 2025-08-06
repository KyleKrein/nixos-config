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
  cfg = config.${namespace}.presets.wayland;
in {
  options.${namespace}.presets.wayland = with types; {
    enable = mkBoolOpt false "Enable preset with MUST HAVE wayland things";
  };

  config = mkIf cfg.enable {
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
    environment.systemPackages = with pkgs; [
      wl-clipboard
      git-credential-manager
      egl-wayland
    ];
    hardware.graphics.enable = true;
  };
}
