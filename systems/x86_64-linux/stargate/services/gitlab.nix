{
  pkgs,
  lib,
  config,
  ...
}: {
  sops.secrets."services/gitlab/dbPassword" = {owner = "gitlab";};
  sops.secrets."services/gitlab/rootPassword" = {owner = "gitlab";};
  sops.secrets."services/gitlab/secret" = {owner = "gitlab";};
  sops.secrets."services/gitlab/otpsecret" = {owner = "gitlab";};
  sops.secrets."services/gitlab/dbsecret" = {owner = "gitlab";};
  sops.secrets."services/gitlab/oidcKeyBase" = {owner = "gitlab";};
  sops.secrets."services/gitlab/activeRecordSalt" = {owner = "gitlab";};
  sops.secrets."services/gitlab/activeRecordPrimaryKey" = {owner = "gitlab";};
  sops.secrets."services/gitlab/activeRecordDeterministicKey" = {owner = "gitlab";};
  services.gitlab = {
    enable = true;
    host = "gitlab.kylekrein.com";
    https = true;
    port = 443;
    statePath = "/var/lib/gitlab/state";
    backup.startAt = "3:00";
    databasePasswordFile = config.sops.secrets."services/gitlab/dbPassword".path;
    initialRootPasswordFile = config.sops.secrets."services/gitlab/rootPassword".path;
    secrets = {
      secretFile = config.sops.secrets."services/gitlab/secret".path;
      otpFile = config.sops.secrets."services/gitlab/otpsecret".path;
      dbFile = config.sops.secrets."services/gitlab/dbsecret".path;
      jwsFile = config.sops.secrets."services/gitlab/oidcKeyBase".path; #pkgs.runCommand "oidcKeyBase" {} "${pkgs.openssl}/bin/openssl genrsa 2048 > $out";
      activeRecordSaltFile = config.sops.secrets."services/gitlab/activeRecordSalt".path;
      activeRecordPrimaryKeyFile = config.sops.secrets."services/gitlab/activeRecordPrimaryKey".path;
      activeRecordDeterministicKeyFile = config.sops.secrets."services/gitlab/activeRecordDeterministicKey".path;
    };
  };

  systemd.services.gitlab-backup.environment.BACKUP = "dump";
}
