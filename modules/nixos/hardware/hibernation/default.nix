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
  cfg = config.${namespace}.hardware.hibernation;
in {
  options.${namespace}.hardware.hibernation = with types; {
    enable = mkBoolOpt false "Enable hibernation";
    swapFileOffset = mkOpt (nullOr int) null "Offset of swapfile. Calculate offset using https://wiki.archlinux.org/title/Power_management/Suspend_and_hibernate#Acquire_swap_file_offset";
    resumeDevice = mkOpt' path "/dev/disk/by-label/nixos";
  };

  config = mkIf cfg.enable {
    boot = {
      kernelParams =
        [
          "mem_sleep_default=deep"
        ]
        #https://github.com/nix-community/disko/issues/651#issuecomment-2383741717
        ++ optional (!config.boot.initrd.systemd.enable) "resume_offset=${builtins.toString cfg.swapFileOffset}";
      inherit (cfg) resumeDevice;
    };
    services.logind = {
      lidSwitch = mkDefault "suspend-then-hibernate";
      powerKey = mkDefault "suspend-then-hibernate";
      powerKeyLongPress = mkDefault "poweroff";
    };
    systemd.sleep.extraConfig = ''
      HibernateDelaySec=30m
      SuspendState=mem
    '';
  };
}
