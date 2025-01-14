{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  emacs = pkgs.emacs;
in {
  services.emacs.enable = true;
  services.emacs.startWithGraphical = true;
  services.emacs.install = true;
  services.emacs.package = emacs; #pkgs.emacs-unstable

  environment.systemPackages = with pkgs; [
    git
    emacs
    ripgrep
    fd
    coreutils
    clang
    (pkgs.writeShellScriptBin "doom-install" ''
      ${pkgs.git}/bin/git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.emacs.d
      ${pkgs.git}/bin/git clone https://github.com/KyleKrein/doomemacs.git ~/.doom.d
      ~/.emacs.d/bin/doom install
      ~/.emacs.d/bin/doom sync
      pidof emacs || ${emacs}/bin/emacs --daemon &
    '')
    (pkgs.writeShellScriptBin "doom-sync" ''
      ~/.emacs.d/bin/doom sync
    '')
    (pkgs.writeShellScriptBin "doom-upgrade" ''
      ~/.emacs.d/bin/doom upgrade
    '')
    (pkgs.writeShellScriptBin "doom" ''
      ${emacs}/bin/emacsclient -c
    '')
  ];
  nixpkgs.overlays = [
    inputs.emacs-overlay.overlays.default
  ];
}
