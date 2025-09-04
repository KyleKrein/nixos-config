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
  cfg = config.${namespace}.impermanence;
  persist = cfg.persistentStorage;
  rootIsBtrfs = config.fileSystems."/".fsType == "btrfs";
in {
  options.${namespace}.impermanence = with types; {
    enable = mkBoolOpt false "Enable impermanence";
    persistentStorage = lib.mkOption {
      type = lib.types.path;
      default = "/persist";
      description = ''
        Volume with persistent information, that won't be destroyed after reboot
      '';
    };
  };

  config = mkIf cfg.enable {
    fileSystems.${persist}.neededForBoot = true;
    environment.persistence."${persist}/system" = {
      hideMounts = true;
      directories = [
        "/etc/ssh"
        "/var/lib/sbctl"
        "/etc/nixos"
        "/var/log"
        "/var/lib/bluetooth"
        "/var/lib/nixos"
        "/var/lib/flatpak"
        "/var/lib/zerotier-one"
        "/var/lib/systemd/coredump"
        "/var/lib/acme"
        "/var/lib/upower"
        "/var/lib/power-profiles-daemon"
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
      "d ${persist}/home/ 0777 root root -" # /persist/home created, owned by root
      "d ${persist}/ollama/ 0755 ollama ollama"
      "d ${persist}/open-webui/ 0755 ollama ollama"
      "d ${persist}/conduwuit/ 0755 conduwuit conduwuit"
      #"d /persist/home/${username} 0700 ${username} users -" # /persist/home/<user> created, owned by that user
      #"d /persist/nixos-config 0700 ${username} users -"
    ];

    programs.fuse.userAllowOther = true;

    #https://blog.decent.id/post/nixos-systemd-initrd/
    boot.initrd.systemd.services.btrfs-rollback-impermanence = lib.mkIf (rootIsBtrfs && config.boot.initrd.systemd.enable) {
      description = "Rollback BTRFS root dataset to blank snapshot";
      wantedBy = ["initrd.target"];
      requires = ["initrd-root-device.target"];
      after = [
        "initrd-root-device.target"
        # LUKS/TPM process
        "systemd-cryptsetup@root_vg.service"
        "local-fs-pre.target"
      ];
      before = [
        "sysroot.mount"
        "create-needed-for-boot-dirs.service"
      ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        mkdir -p /btrfs_tmp
        mount /dev/mapper/root_vg /btrfs_tmp
        if [[ -e /btrfs_tmp/root ]]; then
            mkdir -p /btrfs_tmp/old_roots
            timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
            mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
        fi

        delete_subvolume_recursively() {
            IFS=$'\n'
            for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
                delete_subvolume_recursively "/btrfs_tmp/$i"
            done
            btrfs subvolume delete "$1"
        }

        for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +7); do
            delete_subvolume_recursively "$i"
        done

        btrfs subvolume create /btrfs_tmp/root
        umount /btrfs_tmp
      '';
    };
  };
}
