{
  config,
  lib,
  inputs,
  ...
}: let
in {
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];
  fileSystems."/persist".neededForBoot = true;
  environment.persistence."/persist/system" = {
    hideMounts = true;
    directories = [
      "/etc/nixos"
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/flatpak"
      "/var/lib/zerotier-one"
      "/var/lib/systemd/coredump"
      "/var/lib/acme"
      #"/var/lib/conduwuit"
      "/etc/NetworkManager/system-connections"
      {
        directory = "/var/lib/colord";
        user = "colord";
        group = "colord";
        mode = "u=rwx,g=rx,o=";
      }
    ];
    files = [
      "/etc/machine-id"
      {
        file = "/var/keys/secret_file";
        parentDirectory = {mode = "u=rwx,g=,o=";};
      }
    ];
  };
  systemd.tmpfiles.rules = [
    "d /persist/home/ 0777 root root -" # /persist/home created, owned by root
    "d /persist/ollama/ 0755 ollama ollama"
    "d /persist/open-webui/ 0755 ollama ollama"
    "d /persist/conduwuit/ 0755 conduwuit conduwuit"
    #"d /persist/home/${username} 0700 ${username} users -" # /persist/home/<user> created, owned by that user
    #"d /persist/nixos-config 0700 ${username} users -"
  ];

  programs.fuse.userAllowOther = true;
}
