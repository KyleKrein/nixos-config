{
  lib,
  namespace,
  inputs,
  ...
}:
with lib; rec {
  mkHomeManagerConfigOpt = config: lib.${namespace}.mkOpt' types.anything {};

  mkUser = {
    config,
    enable,
    homeConfig,
    username,
    admin,
    extraGroups,
    trustedSshKeys,
  }: let
    impermanence = config.${namespace}.impermanence;
    persist = impermanence.persistentStorage;
  in {
    snowfallorg.users.${username} = {
      create = enable;
      inherit admin;

      home = {
        enable = enable;
        #config = homeConfig;
      };
    };
    users.users.${username} = mkIf enable {
      extraGroups = extraGroups ++ optionals admin ["wheel"];
      hashedPasswordFile = config.sops.secrets."users/${username}".path;
      openssh.authorizedKeys.keys = trustedSshKeys;
    };
    sops.secrets."users/${username}" = mkIf enable {
      neededForUsers = true;
    };
    systemd.tmpfiles.rules = optionals (impermanence.enable) ["d ${persist}/home/${username} 0700 ${username} users -"]; # /persist/home/<user> created, owned by that user

    nix.settings.trusted-users = optionals admin [
      username
    ];
  };
}
