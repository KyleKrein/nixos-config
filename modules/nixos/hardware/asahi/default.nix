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
  cfg = config.${namespace}.hardware.asahi;
in {
  options.${namespace}.hardware.asahi = with types; {
    enable = mkBoolOpt false "Enable hardware support for Apple Silicon (M Chips)";
    imports = [
      inputs.apple-silicon-support.nixosModules.default
      ({pkgs, ...}: {
        hardware.asahi = {
          peripheralFirmwareDirectory = ./firmware;
          useExperimentalGPUDriver = true; #deprecated
          #experimentalGPUInstallMode = "overlay";
          setupAsahiSound = true;
        };
        environment.systemPackages = with pkgs; [
          mesa-asahi-edge
        ];
      })
    ];
  };
}
