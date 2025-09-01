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
  cfg = config.${namespace}.programs.xournalpp;
  impermanence = config.${namespace}.impermanence;
in {
  options.${namespace}.programs.xournalpp = with types; {
    enable = mkBoolOpt false "Enable xournal++";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [xournalpp];
    home.persistence = mkIf impermanence.enable {
      "${impermanence.persistentStorage}".directories = [
        ".config/xournalpp"
      ];
    };
  };
}
