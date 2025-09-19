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
with lib.custom; {
  #https://wiki.nixos.org/wiki/Immich
  services.immich = {
    enable = true;
    port = 2283;
    accelerationDevices = null;
  };
  users.users.immich.extraGroups = ["video" "render"];
  hardware.graphics = {
    enable = true;
  };
  #networking.firewallAllowedTCPPorts = [config.services.immich.port];
}
