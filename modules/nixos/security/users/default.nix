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
with lib.${namespace}; let
  cfg = config.${namespace}.security.users;
in {
  options.${namespace}.security.users = with types; {
    enable = mkBoolOpt true "Enable security measures for users, that include immutable users, disabled root access and ssh rules";
  };

  config = mkIf cfg.enable {
    users = {
      mutableUsers = false;
      users = {
        root = {
          # disable root login here, and also when installing nix by running nixos-install --no-root-passwd
          # https://discourse.nixos.org/t/how-to-disable-root-user-account-in-configuration-nix/13235/3
          hashedPassword = "!"; # disable root logins, nothing hashes to !
        };
      };
    };
    # Enable the OpenSSH daemon.
    services.openssh = {
      enable = true;
      # require public key authentication for better security
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
      #settings.PermitRootLogin = "no";
    };
    networking.firewall.allowedTCPPorts = [22];
    networking.firewall.allowedUDPPorts = [22];
  };
}
