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
  cfg = config.${namespace}.services.syncthing;
  impermanence = config.${namespace}.impermanence;
in {
  options.${namespace}.services.syncthing = with types; {
    enable = mkBoolOpt false "Enable syncthing service for the user";
    user = lib.mkOption {
        type = lib.types.singleLineStr;
        default = "";
        example = "nixos";
        description = ''
          User, that will use the syncthing service (only one at a time)
        '';
      };
  };

  config =
    mkIf cfg.enable {
      systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true"; # Don't create default ~/Sync folder
  services.syncthing = {
    inherit (cfg) user;
    configDir = optional (impermanence.enable) "${impermanence.persistentStorage}/home/${cfg.user}/.config/syncthing";
    enable = true;
  };
    };
}
