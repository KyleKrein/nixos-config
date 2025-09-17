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
  facter.reportPath = ./facter.json;
  imports = lib.snowfall.fs.get-nix-files ./.;
  systemd.network.wait-online.enable = lib.mkForce false; #facter

  custom.presets.disko.impermanenceBtrfsLuks = {
    enable = true;
    swapSize = 16;
  };
  custom.hardware.secureBoot = enabled;
  custom.impermanence = enabled;

  custom.users.kylekrein = {
    enable = true;
    config = {};
  };
  networking.firewall.allowedTCPPorts = [80 443 22];
  # ======================== DO NOT CHANGE THIS ========================
  system.stateVersion = "25.05";
  # ======================== DO NOT CHANGE THIS ========================
}
