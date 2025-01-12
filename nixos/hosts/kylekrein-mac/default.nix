{
  pkgs,
  lib,
  hwconfig,
  inputs,
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
}
