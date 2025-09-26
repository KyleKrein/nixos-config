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
  cfg = config.${namespace}.presets.disko.impermanenceBtrfsLuks;
in {
  options.${namespace}.presets.disko.impermanenceBtrfsLuks = with types; {
    enable = mkBoolOpt false "Enable preset";
    device = mkOpt' str "/dev/nvme0n1";
    swapSize = mkOpt' (nullOr int) 32;
  };

  config = mkIf cfg.enable {
    ${namespace}.impermanence = {
      enable = true;
      persistentStorage = "/persist";
    };
    disko.devices = {
      disk = {
        main = {
          type = "disk";
          inherit (cfg) device;
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
		    "umask=0077"
                  ];
                };
              };
              luks = {
                size = "100%";
                label = "luks";
                content = {
                  type = "luks";
                  name = "root_vg";
                  extraOpenArgs = [
                    "--allow-discards"
                    "--perf-no_read_workqueue"
                    "--perf-no_write_workqueue"
                  ];
                  # https://0pointer.net/blog/unlocking-luks2-volumes-with-tpm2-fido2-pkcs11-security-hardware-on-systemd-248.html
                  settings = {crypttabExtraOpts = ["fido2-device=auto" "token-timeout=10"];};
                  content = {
                    type = "btrfs";
                    extraArgs = ["-L" "nixos" "-f"];
                    subvolumes = {
                      "/root" = {
                        mountpoint = "/";
                        mountOptions = ["subvol=root" "compress=zstd" "noatime"];
                      };
                      "/nix" = {
                        mountpoint = "/nix";
                        mountOptions = ["subvol=nix" "compress=zstd" "noatime"];
                      };
                      "/persist" = {
                        mountpoint = "/persist";
                        mountOptions = ["subvol=persist" "compress=zstd" "noatime"];
                      };
                      "/swap" = mkIf (cfg.swapSize != null) {
                        mountpoint = "/swap";
                        swap.swapfile.size = "${builtins.toString cfg.swapSize}G";
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };
    };

    fileSystems."/persist".neededForBoot = true;
  };
}
