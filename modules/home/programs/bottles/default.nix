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
  cfg = config.${namespace}.programs.bottles;
  impermanence = config.${namespace}.impermanence;
in {
  options.${namespace}.programs.bottles = with types; {
    enable = mkBoolOpt false "Enable Bottles";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [bottles];
    home.persistence = mkIf impermanence.enable {
      "${impermanence.persistentStorage}".directories = [
        {
          directory = ".local/share/bottles";
          method = "symlink";
        }
      ];
    };
  };
}
