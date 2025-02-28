{
  pkgs,
  lib,
  hwconfig,
  inputs,
  config,
  ...
}: {
  imports = [
    inputs.apple-silicon-support.nixosModules.default
    ./mac-hardware-conf.nix
    ../../hardware/apple-silicon-linux

    ../../modules/hyprland

    ../../users/kylekrein
  ];
  sops.secrets."ssh_keys/${hwconfig.hostname}" = {};
  facter.reportPath = lib.mkForce null; #fails to generate
  boot.binfmt.emulatedSystems = [ "x86_64-linux" ];
  nix.settings.extra-platforms = config.boot.binfmt.emulatedSystems;
  
  services.displayManager.sddm = {
      wayland.enable = lib.mkForce false; # black screen
    };
}
