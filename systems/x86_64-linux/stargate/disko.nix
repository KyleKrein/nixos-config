{lib, ...}: let
  addHdd = device: name: {
    type = "disk";
    inherit device;
    content = {
      type = "gpt";
      partitions = {
        luks = {
          size = "100%";
          label = "luks-${name}";
          content = {
            type = "luks";
            inherit name;
            extraOpenArgs = [
              "--allow-discards"
              "--perf-no_read_workqueue"
              "--perf-no_write_workqueue"
            ];
            # https://0pointer.net/blog/unlocking-luks2-volumes-with-tpm2-fido2-pkcs11-security-hardware-on-systemd-248.html
            settings = {
              keyFile = "/tmp/secret.key";
              crypttabExtraOpts = [
                "fido2-device=auto"
                "token-timeout=10"
              ];
            };
            content = {
              type = "zfs";
              pool = "zstorage";
            };
          };
        };
      };
    };
  };
in {
  disko.devices = {
    disk = {
      hdd1 = addHdd "/dev/sda" "crypt-hdd1";
      hdd2 = addHdd "/dev/sdb" "crypt-hdd2";
      hdd3 = addHdd "/dev/sdc" "crypt-hdd3";
      hdd4 = addHdd "/dev/sdd" "crypt-hdd4";
    };
    zpool = {
      zstorage = {
        type = "zpool";
        mode = "raidz2";
        options.compression = "zstd";
        options.ashift = "12";
	mountpoint = "none";
        datasets = {
          "services" = {
            type = "zfs_fs";
            mountpoint = "/var/lib";
            options."com.sun:auto-snapshot" = "true";
          };
          "backups" = {
            type = "zfs_fs";
            mountpoint = "/backups";
            options."com.sun:auto-snapshot" = "true";
          };
          "media" = {
            type = "zfs_fs";
            mountpoint = "/media";
            options."com.sun:auto-snapshot" = "true";
          };
        };
      };
    };
  };
}
