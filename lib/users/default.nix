{
  lib,
  namespace,
  ...
}:
with lib; rec {
  mkHomeManagerConfigOpt = config:
    mkOption {
      # HM-compatible options taken from:
      # https://github.com/nix-community/home-manager/blob/0ee5ab611dc1fbb5180bd7d88d2aeb7841a4d179/nixos/common.nix#L14
      # NOTE: This has been adapted to support documentation generation without
      # having home-manager options fully declared.
      type = types.submoduleWith {
        specialArgs =
          {
            osConfig = config;
            modulesPath = "${inputs.home-manager or "/"}/modules";
          }
          // (config.home-manager.extraSpecialArgs or {});
        modules =
          [
            ({
              lib,
              modulesPath,
              ...
            }:
              if inputs ? home-manager
              then {
                imports = import "${modulesPath}/modules.nix" {
                  inherit pkgs lib;
                  useNixpkgsModule = !(config.home-manager.useGlobalPkgs or false);
                };

                config = {
                  submoduleSupport.enable = true;
                  submoduleSupport.externalPackageInstall = config.home-manager.useUserPackages;

                  home.username = config.users.users.${name}.name;
                  home.homeDirectory = config.users.users.${name}.home;

                  nix.package = config.nix.package;
                };
              }
              else {})
          ]
          ++ (config.home-manager.sharedModules or []);
      };
    };

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
        config = homeConfig;
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
