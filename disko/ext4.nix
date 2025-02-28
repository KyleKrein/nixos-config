{ device, mountpoint ? "/run/extraDrive" }:
{
  disko.devices = {
    disk = {
      "${device}" = {
        inherit device;
        type = "disk";
        content = {
          type = "gpt";
	  partitions = {
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                inherit mountpoint;
              };
            };
          };
        };
      };
    };
  };
}
