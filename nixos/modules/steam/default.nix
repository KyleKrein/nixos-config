{
  pkgs,
  lib,
  config,
  hwconfig,
  ...
}: let
  cfg = config.kk.steam;
in {
  options.kk.steam = {
    enable = lib.mkEnableOption "Enable steam";
  };

  config = lib.mkIf cfg.enable (
    if hwconfig.useImpermanence
    then {
      kk.services.flatpak.enable = lib.mkForce true;
      services.flatpak.packages = ["com.valvesoftware.Steam"];
    }
    else {
      programs.steam = {
        enable = !hwconfig.useImpermanence;
        remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
        dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
        localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
      };
    }
  );
}