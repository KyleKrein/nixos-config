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
  services.ntfy-sh = {
    enable = true;
    settings = {
      base-url = "https://ntfy.kylekrein.com";
      listen-http = ":9000";
      #auth-default-access = "read-only";
      smtp-server-listen = ":1299";
      smtp-server-domain = "localhost.com";
      behind-proxy = true;
      enable-login = true;
      cache-file = "/var/lib/ntfy-sh/cache-file.db";
      auth-file = "/var/lib/ntfy-sh/user.db";
      attachment-cache-dir = "/var/lib/ntfy-sh/attachments";
    };
  };

  services.postfix = {
    enable = true;
    config = {
      myhostname = "stargate.local";
      mydestination = "localhost, localhost.com";
      relayhost = "";
      transport_maps = "hash:/etc/postfix.conf";
    };
  };

  environment.etc."postfix.conf".text = ''
    localhost.com   smtp:[127.0.0.1]:1299
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
