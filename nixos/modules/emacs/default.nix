{
  config,
  pkgs,
  lib,
  inputs,
  hwconfig,
  ...
}: let
  emacs = inputs.emacs-kylekrein.packages.${hwconfig.system}.with-lsps;
in {
  services.emacs.enable = true;
  services.emacs.startWithGraphical = true;
  services.emacs.install = true;
  services.emacs.package = emacs;

  environment.systemPackages = [emacs];
}
