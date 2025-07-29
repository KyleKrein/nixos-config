{pkgs, ...}: {
  boot = {
    kernelParams = [
      "resume_offset=533760"
      "mem_sleep_default=deep"
    ];
    resumeDevice = "/dev/disk/by-label/nixos";
  };
  services.logind = {
    lidSwitch = "suspend-then-hibernate";
    powerKey = "suspend-then-hibernate";
    powerKeyLongPress = "poweroff";
  };
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30m
    SuspendState=mem
  '';
}
