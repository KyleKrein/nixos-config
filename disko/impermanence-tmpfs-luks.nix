{
  device ? throw "Set this to your disk device, e.g. /dev/sda",
  ...
}:
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = device;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              label = "boot";
              name = "ESP";
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                ];
              };
            };
            luks = {
              size = "100%";
              label = "luks";
              content = {
                type = "luks";
                name = "cryptroot";
                extraOpenArgs = [
                  "--allow-discards"
                  "--perf-no_read_workqueue"
                  "--perf-no_write_workqueue"
                ];
                # https://0pointer.net/blog/unlocking-luks2-volumes-with-tpm2-fido2-pkcs11-security-hardware-on-systemd-248.html
                settings = {crypttabExtraOpts = ["fido2-device=auto" "token-timeout=10"];};
                content = {
                  type = "filesystem";
                  format = "ext4";
		  mountpoint = "/persist";
		  };
                };
              };
            };
          };
        };
      };
    nodev = {
      "/" = {
        fsType = "tmpfs";
	mountOptions = [ "defaults" "size=8G" "mode=755" ];
      };
    };
  };

  fileSystems."/persist" = {
    depends = [ "/" ];
    neededForBoot = true;
  };
  fileSystems."/nix" = {
    device = "/persist/nix";
    options = [ "bind" ];
    depends = [ "/persist" ];
    neededForBoot = true;
  };
  fileSystems."/tmp" = {
    device = "/persist/tmp";
    options = [ "bind" ];
    depends = [ "/persist" ];
    neededForBoot = true;
  };
  swapDevices = [{
    device = "/persist/swapfile";
    size = 64*1024; # 64 GB
  }];

  boot.resumeDevice = "/persist/swapfile";
}
