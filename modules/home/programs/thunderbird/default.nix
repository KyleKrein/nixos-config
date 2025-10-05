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
  cfg = config.${namespace}.programs.thunderbird;
  impermanence = config.${namespace}.impermanence;
in {
  options.${namespace}.programs.thunderbird = with types; {
    enable = mkBoolOpt false "Enable Thunderbird";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [thunderbird];
    home.persistence = mkIf impermanence.enable {
      "${impermanence.persistentStorage}".directories = [
        {
          directory = ".thunderbird";
          method = "symlink";
        }
      ];
    };
  };
}
