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
  cfg = config.${namespace}.presets.disko.ext4;
in {
  options.${namespace}.presets.disko.ext4 = with types; {
    enable = mkBoolOpt false "Enable preset";
    device = mkOpt' str "/dev/nvme0n1";
    mountpoint = mkOpt' path "/";
  };

  config = mkIf cfg.enable {
    disko.devices = {
      disk = {
        "${cfg.device}" = {
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
                  inherit (cfg) mountpoint;
                };
              };
            };
          };
        };
      };
    };
  };
}
