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
  cfg = config.${namespace}.programs.nheko;
  impermanence = config.${namespace}.impermanence;
in {
  options.${namespace}.programs.nheko = with types; {
    enable = mkBoolOpt false "Enable Nheko - Matrix client written in C++";
  };

  config = mkIf cfg.enable {
    programs.nheko.enable = true;

    home.persistence = mkIf impermanence.enable {
      "${impermanence.persistentStorage}".directories = [
        ".config/nheko"
        ".local/share/nheko"
        ".cache/nheko"
      ];
    };
  };
}
