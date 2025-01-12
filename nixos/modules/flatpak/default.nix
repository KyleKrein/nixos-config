{
  pkgs,
  lib,
  inputs,
  config,
  ...
}: let
  cfg = config.kk.services.flatpak;
in {
  imports = [
    inputs.nix-flatpak.nixosModules.nix-flatpak
  ];
  options.kk.services.flatpak = {
    enable = lib.mkEnableOption "enable flatpaks";
  };
  config = lib.mkIf cfg.enable {
    services.flatpak.enable = true;
  };
}
