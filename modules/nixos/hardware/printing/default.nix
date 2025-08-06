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
  cfg = config.${namespace}.hardware.printing;
in {
  options.${namespace}.hardware.printing = with types; {
    enable = mkBoolOpt false "Enable printers support";
  };

  config =
    mkIf cfg.enable {
      environment.systemPackages = with pkgs; [
system-config-printer
];
      services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
    };
}
