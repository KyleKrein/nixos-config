{
  lib,
  pkgs,
  config,
  ...
}: {
  sops.secrets."duckdns" = {};
  systemd.timers."duckdns" = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "5m";
      Unit = "duckdns.service";
    };
  };

  systemd.services."duckdns" = {
    script = let
      duckdns = pkgs.writeShellScriptBin "duckdns" ''
        TOKEN=$(${pkgs.coreutils}/bin/cat ${config.sops.secrets."duckdns".path})
        REALV6=$(${pkgs.iproute2}/bin/ip -6 addr show dev enp3s0 scope global \
         | ${pkgs.gawk}/bin/awk '/inet6 2/{print $2}' \
         | ${pkgs.coreutils}/bin/cut -d/ -f1 \
         | ${pkgs.gnugrep}/bin/grep -E 'f9c4$' \
         | ${pkgs.coreutils}/bin/head -n1)
        REALV4=$(${pkgs.curl}/bin/curl -s https://ifconfig.me --ipv4)
        ${pkgs.coreutils}/bin/echo url="https://www.duckdns.org/update?domains=kylekrein&token=$TOKEN&ipv6=$REALV6&ip=$REALV4" | ${pkgs.curl}/bin/curl -k -K -
      '';
    in ''
      set -eu
      out=$(${duckdns}/bin/duckdns)
      ${pkgs.coreutils}/bin/echo "Sent new IP Address to DuckDNS: $out"
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
