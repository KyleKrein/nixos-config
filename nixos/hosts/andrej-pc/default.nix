{
  pkgs,
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

  #sops.secrets."ssh_keys/${hwconfig.hostname}" = {};
  systemd.network.wait-online.enable = lib.mkForce false;
}
