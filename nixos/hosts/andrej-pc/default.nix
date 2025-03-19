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

  zramSwap = {
    enable = true; # Hopefully? helps with freezing when using swap
  };

  services.zerotierone = {
    enable = true;
    joinNetworks = [
      "a09acf0233dccb4a"
    ];
  };

  hardware.nvidia.open = lib.mkForce false;
  #hardware.nvidia.package = lib.mkForce config.boot.kernelPackages.nvidiaPackages.latest;
  #sops.secrets."ssh_keys/${hwconfig.hostname}" = {};
  systemd.network.wait-online.enable = lib.mkForce false;
}
