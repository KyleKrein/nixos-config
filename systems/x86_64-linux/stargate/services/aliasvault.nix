{
  pkgs,
  lib,
  config,
  ...
}: {
  systemd.tmpfiles.rules = [
    # format: type path mode uid gid age argument
    "d /var/lib/aliasvault 0750 100 102 - -"
    "d /var/lib/aliasvault/database 0700 100 102 - -"
    "d /var/lib/aliasvault/logs 0750 100 102 - -"
    "d /var/lib/aliasvault/secrets 0750 100 102 - -"
  ];
  # Подман
  virtualisation.podman.enable = true;
  virtualisation.oci-containers.backend = "podman";

  virtualisation.oci-containers.containers.aliasvault = {
    image = "ghcr.io/aliasvault/aliasvault:latest";
    autoStart = true;

    ports = [
      "127.0.0.1:8086:80"
      "127.0.0.1:8444:443"
      "127.0.0.1:2525:25"
      "127.0.0.1:5877:587"
    ];

    volumes = [
      "/var/lib/aliasvault/database:/database:rw"
      "/var/lib/aliasvault/logs:/logs:rw"
      "/var/lib/aliasvault/secrets:/secrets:rw"
    ];

    environment = {
      HOSTNAME = "pass.kylekrein.com";
      PUBLIC_REGISTRATION_ENABLED = "false";
      IP_LOGGING_ENABLED = "true";
      FORCE_HTTPS_REDIRECT = "false"; # SSL делаем на nginx
      SUPPORT_EMAIL = "";
      PRIVATE_EMAIL_DOMAINS = "notthebees.org";
    };
  };

  # Nginx
  services.nginx.virtualHosts."pass.kylekrein.com" = {
    enableACME = true;
    forceSSL = true;

    locations = {
      "/" = {
        proxyPass = "http://localhost:8086/";
        proxyWebsockets = true;
      };
    };
  };

  # Firewall
  networking.firewall.allowedTCPPorts = [80 443 587 25];
}
