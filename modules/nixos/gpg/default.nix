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
  cfg = config.${namespace}.gpg;
in {
  options.${namespace}.gpg = with types; {
    enable = mkBoolOpt false "Enable gpg with emacs/terminal support";
  };

  config = mkIf cfg.enable {
    programs.gnupg.agent = {
      enable = true;
      settings = {
        pinentry-program = lib.mkForce "${pkgs.pinentry-curses}/bin/pinentry-curses";
      };
    };
  };
}
