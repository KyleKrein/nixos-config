{
  pkgs,
  lib,
  hwconfig,
  ...
}: {
  boot = {
    initrd.systemd.enable = true;

    loader.systemd-boot.enable = lib.mkForce false;

    lanzaboote = {
      enable = true;
      pkiBundle =
        #if hwconfig.useImpermanence
        #then "/persist/system/var/lib/sbctl"
        #        else
        "/var/lib/sbctl";
    };
  };
  environment.systemPackages = [
    # For debugging and troubleshooting Secure Boot.
    pkgs.sbctl
    # For tpm auto unlock
    pkgs.tpm2-tss
  ];
}
