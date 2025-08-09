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
  cfg = config.${namespace}.programs.prismlauncher;
  impermanence = config.${namespace}.impermanence;
in {
  options.${namespace}.programs.prismlauncher = with types; {
    enable = mkBoolOpt false "Enable prismlauncher";
  };

  config = mkIf cfg.enable (mkIf impermanence.enable {
      home.persistence."${impermanence.persistentStorage}".directories = [
        {
          directory = ".local/share/Prismlauncher";
          method = "symlink";
        }
      ];
    }
    // {
      home.packages = with pkgs; [prismlauncher];
    });
}
