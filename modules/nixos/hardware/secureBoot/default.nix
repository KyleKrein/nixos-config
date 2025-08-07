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
  cfg = config.${namespace}.hardware.secureBoot;
in {
  options.${namespace}.hardware.secureBoot = with types; {
    enable = mkBoolOpt false "Enable support for secure boot. Note: Secure boot should still be configured imperatively. This module only handles the declarative part.";
  };

  config = mkIf cfg.enable {
    boot = {
      initrd.systemd.enable = true;

      lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";
      };
    };
    environment.systemPackages = with pkgs; [
      # For debugging and troubleshooting Secure Boot.
      sbctl
      # For tpm auto unlock
      tpm2-tss
    ];
  };
}
