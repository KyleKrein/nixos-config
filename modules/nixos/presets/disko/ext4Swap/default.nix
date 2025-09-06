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
  cfg = config.${namespace}.presets.disko.ext4Swap;
in {
  options.${namespace}.presets.disko.ext4Swap = with types; {
    enable = mkBoolOpt false "Enable preset";
    device = mkOpt' str "/dev/nvme0n1";
    swapSize = mkOpt' int 32;
    mountpoint = mkOpt' path "/";
  };

  config = mkIf cfg.enable {
    disko.devices = {
      disk.${cfg.device} = {
        type = "disk";
        inherit (cfg) device;
        content = {
          type = "gpt"; # Initialize the disk with a GPT partition table
          partitions = {
            ESP = {
              # Setup the EFI System Partition
              type = "EF00"; # Set the partition type
              size = "1000M"; # Make the partition a gig
              content = {
                type = "filesystem";
                format = "vfat"; # Format it as a FAT32 filesystem
                mountpoint = "/boot"; # Mount it to /boot
              };
            };
            primary = {
              # Setup the LVM partition
              size = "100%"; # Fill up the rest of the drive with it
              content = {
                type = "lvm_pv"; # pvcreate
                vg = "vg1";
              };
            };
          };
        };
      };
      lvm_vg = {
        # vgcreate
        vg1 = {
          # /dev/vg1
          type = "lvm_vg";
          lvs = {
            # lvcreate
            swap = {
              # Logical Volume = "swap", /dev/vg1/swap
              size = "${builtins.toString cfg.swapSize}G";
              content = {
                type = "swap";
              };
            };
            root = {
              # Logical Volume = "root", /dev/vg1/root
              size = "100%FREE"; # Use the remaining space in the Volume Group
              content = {
                type = "filesystem";
                format = "ext4";
                inherit (cfg) mountpoint;
                mountOptions = [
                  "defaults"
                ];
              };
            };
          };
        };
      };
    };
  };
}
