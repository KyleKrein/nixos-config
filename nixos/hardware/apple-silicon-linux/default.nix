{
  pkgs,
  lib,
  ...
}: let
in {
  #nixpkgs.overlays = [
  #    (import ./widevine-overlay.nix)
  #];
  #nixpkgs.config.allowUnsupportedSystem = true;
  imports = [
    #./apple-silicon-support
  ];
  hardware.asahi = {
    peripheralFirmwareDirectory = ./firmware;
    useExperimentalGPUDriver = true;
    experimentalGPUInstallMode = "overlay";
    setupAsahiSound = true;
  };

  #powerManagement = {
  #    enable = true;
  #    powertop.enable = true;
  #};
  #hardware.graphics.enable32Bit = lib.mkForce false;
  environment.systemPackages = with pkgs; [
    #mesa
    #mesa.drivers
    mesa-asahi-edge
    #widevine-cdm
    #widevinecdm-aarch64
  ];
}
