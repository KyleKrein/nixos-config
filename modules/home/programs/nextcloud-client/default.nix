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
  cfg = config.${namespace}.programs.nextcloud-client;
  impermanence = config.${namespace}.impermanence;
in {
  options.${namespace}.programs.nextcloud-client = with types; {
    enable = mkBoolOpt false "Enable nextcloud-client";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nextcloud-client
    ];
    home.persistence = mkIf impermanence.enable {
      "${impermanence.persistentStorage}".directories = [
        ".config/Nextcloud"
      ];
    };
  };
}
