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

    ../../modules/cosmic

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
      "1d71939404962783"
      "41d49af6c260338d"
    ];
  };

  hardware.nvidia.open = lib.mkForce false;
  #hardware.nvidia.package = lib.mkForce config.boot.kernelPackages.nvidiaPackages.latest;
  #sops.secrets."ssh_keys/${hwconfig.hostname}" = {};
  systemd.network.wait-online.enable = lib.mkForce false;
}
