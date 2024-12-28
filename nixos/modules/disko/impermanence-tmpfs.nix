{
  device ? throw "Set this to your disk device, e.g. /dev/sda",
  ...
}: {
  disko.devices = {
    disk.main = {
      inherit device;
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            name = "boot";
            size = "1M";
            type = "EF02";
          };
          esp = {
            name = "ESP";
            size = "500M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          root = {
            name = "root";
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
	      mountpoint = "/persist";
            };
          };
        };
      };
    };
    nodev = {
      "/" = {
        fsType = "tmpfs";
      };
      "/nix" = {
	    device = "/persist/nix";
      };
      "/tmp" = {
	device = "/persist/tmp";
      };
    };
  };
}
