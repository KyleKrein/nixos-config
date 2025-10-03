{
  pkgs,
  lib,
  config,
  ...
}: {
  services.postfix = {
    enable = true;
    config = {
      myhostname = "stargate.local";
      mydestination = "localhost, localhost.com";

      relay_domains = "notthebees.org";
      transport_maps = "hash:/etc/postfix.conf";
      inet_interfaces = "all";
    };
  };

  environment.etc."postfix.conf".text = ''
    localhost.com   smtp:[127.0.0.1]:1299
    notthebees.org   smtp:[127.0.0.1]:2525
  '';
  systemd.services.postmap-transport = {
    description = "Generate postfix transport.db from transport";
    wantedBy = ["multi-user.target"];
    before = ["postfix.service"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.postfix}/bin/postmap /etc/postfix.conf";
    };
  };
}
