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
with lib.custom; let
  zfsCompatibleKernelPackages =
    lib.filterAttrs (
      name: kernelPackages:
        (builtins.match "linux_[0-9]+_[0-9]+" name)
        != null
        && (builtins.tryEval kernelPackages).success
        && (!kernelPackages.${config.boot.zfs.package.kernelModuleAttribute}.meta.broken)
    )
    pkgs.linuxKernel.packages;
  latestKernelPackage = lib.last (
    lib.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)) (
      builtins.attrValues zfsCompatibleKernelPackages
    )
  );
in {
  facter.reportPath =
    if (builtins.pathExists ./facter.json)
    then ./facter.json
    else null;
  imports = lib.snowfall.fs.get-non-default-nix-files ./. ++ [./services];
  #systemd.network.wait-online.enable = lib.mkForce false; #facter
  boot.supportedFilesystems = ["zfs"];
  # Note this might jump back and forth as kernels are added or removed.
  boot.kernelPackages = latestKernelPackage;
  networking.hostId = "049b86a7"; # head -c4 /dev/urandom | od -A none -t x4
  services.zfs.autoScrub = {
    enable = true;
    interval = "*-*-1,15 02:30";
  };
  services.sanoid = {
    enable = true;
    templates.backup = {
      hourly = 36;
      daily = 30;
      monthly = 3;
      autoprune = true;
      autosnap = true;
    };

    datasets."zstorage/services" = {
      useTemplate = ["backup"];
    };
    datasets."zstorage/media" = {
      useTemplate = ["backup"];
    };
    datasets."zstorage/backup" = {
      useTemplate = ["backup"];
    };
  };

  services.syncoid = {
    enable = false; #TODO Configure backups
    user = "backupuser";
    commonArgs = ["--no-sync-snap" "--skip-parent" "--recursive"];
    sshKey = "/var/lib/syncoid/backup";
    commands."backup1" = {
      source = "rpool/data";
      target = "backup1";
    };
    commands."truenas" = {
      source = "rpool/data";
      target = "backupuser@192.168.200.103:backuppool/data";
      extraArgs = ["--sshoption=StrictHostKeyChecking=off"];
    };
  };
  sops.secrets."duckdns" = {mode = "777";};
  services.cron = {
    enable = true;
    systemCronJobs = [
      "*/5 * * * * ${lib.getExe (pkgs.writeShellScriptBin "duckdns" ''
        TOKEN=$(cat ${config.sops.secrets."duckdns".path})
        REALV6=$(ip -6 addr show dev enp3s0 scope global \
         | awk '/inet6 2/{print $2}' \
         | cut -d/ -f1 \
         | grep -E 'f9c4$' \
         | head -n1)
        REALV4=$(curl -s https://ifconfig.me --ipv4)
        echo url="https://www.duckdns.org/update?domains=kylekrein&token=$TOKEN&ipv6=$REALV6&ip=$REALV4" | curl -k -K -
      '')} >/dev/null 2>&1"
    ];
  };

  custom.presets.disko.impermanenceBtrfsLuks = {
    enable = true;
    swapSize = null;
  };
  custom.presets.default = enabled;
  custom.hardware.secureBoot = enabled;
  custom.impermanence = enabled;

  custom.users.kylekrein = {
    enable = true;
    config = {};
  };
  networking.firewall.allowedTCPPorts = [80 443 22];
  # ======================== DO NOT CHANGE THIS ========================
  system.stateVersion = "25.05";
  # ======================== DO NOT CHANGE THIS ========================
}
