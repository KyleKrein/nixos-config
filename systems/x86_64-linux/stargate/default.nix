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
with lib.custom; {
  #facter.reportPath = ./facter.json;
  imports = lib.snowfall.fs.get-non-default-nix-files ./. ++ [./services];
  #systemd.network.wait-online.enable = lib.mkForce false; #facter
  boot.supportedFilesystems = ["zfs"];
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

  custom.presets.disko.impermanenceBtrfsLuks = {
    enable = true;
    swapSize = null;
  };
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
