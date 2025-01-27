{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  emacs = pkgs.emacs-pgtk; # pkgs.emacs; #pkgs.emacs-pgtk;
in
{
  #services.emacs.enable = true;
  services.emacs.startWithGraphical = true;
  #services.emacs.install = true;
  services.emacs.package = emacs; # pkgs.emacs-unstable

  environment.systemPackages =
    (import ./packages.nix {
      inherit pkgs;
      inherit emacs;
    }).packages;
  nixpkgs.overlays = [
    inputs.emacs-overlay.overlays.default
  ];
}
