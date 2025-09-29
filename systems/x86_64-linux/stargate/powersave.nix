{
  lib,
  pkgs,
  config,
  ...
}: {
  powerManagement.powertop.enable = true;
  environment.systemPackages = with pkgs; [
    powertop
  ];
  systemd.services.hd-idle = {
    enable = false;
    description = "External HD spin down daemon";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "forking";
      ExecStart = "${pkgs.hd-idle}/bin/hd-idle -i 1800 -l /var/log/hd-idle.log";
      ExecReload = "pkill hd-idle";
    };
  };
}
