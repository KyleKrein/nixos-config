{
  pkgs,
  lib,
  inputs,
  ...
}: let
pkgs-master = import inputs.nixpkgs-master {
  inherit (pkgs) system;
  config.allowUnfree = true;
};
in {
nixpkgs = {
    overlays = [
      (self: super: {
        widevine-cdm = pkgs-master.widevine-cdm;
      })
    ];
  };
  #nixpkgs.overlays = [
  #    (import ./widevine-overlay.nix)
  #];
  #nixpkgs.config.allowUnsupportedSystem = true;
  imports = [
    #./apple-silicon-support
  ];
programs.firefox.policies.Preferences = {
  "media.gmp-widevinecdm.version" = "system-installed";
  "media.gmp-widevinecdm.visible" = true;
  "media.gmp-widevinecdm.enabled" = true;
  "media.gmp-widevinecdm.autoupdate" = false;
  "media.eme.enabled" = true;
  "media.eme.encrypted-media-encryption-scheme.enabled" = true;
};
programs.firefox.autoConfig = ''
// Zhu
lockPref("general.useragent.override","Mozilla/5.0 (X11; CrOS aarch64 15236.80.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.5414.125 Safari/537.36");''; #doesn't work. You need to manually add this to about:config
  hardware.asahi = {
    peripheralFirmwareDirectory = ./firmware;
    useExperimentalGPUDriver = true; #deprecated
    #experimentalGPUInstallMode = "overlay";
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
