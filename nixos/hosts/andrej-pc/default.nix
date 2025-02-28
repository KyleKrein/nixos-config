{
  pkgs,
  config,
  lib,
  hwconfig,
  inputs,
  ...
}: {
  imports = [
    ../../hardware/nvidia

    ../../modules/kde-plasma

    ../../users/kylekrein

    ../../users/andrej
  ];

  hardware.nvidia.open = lib.mkForce false;
  hardware.nvidia.package = lib.mkForce config.boot.kernelPackages.nvidiaPackages.stable;
  #sops.secrets."ssh_keys/${hwconfig.hostname}" = {};
  systemd.network.wait-online.enable = lib.mkForce false;
}
