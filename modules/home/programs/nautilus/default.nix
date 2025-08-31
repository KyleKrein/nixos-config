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
  cfg = config.${namespace}.programs.nautilus;
in {
  options.${namespace}.programs.nautilus = with types; {
    enable = mkBoolOpt false "Enable nautilus on platforms, that are not GNOME";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nautilus
      adwaita-icon-theme
    ];
  };
}
