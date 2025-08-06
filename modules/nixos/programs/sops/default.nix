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
  cfg = config.${namespace}.programs.sops;
  impermanence = config.${namespace}.impermanence;
  keyPath =
    if impermanence.enable
    then "${impermanence.persistentStorage}/sops/age/keys.txt"
    else "/var/lib/sops/age/keys.txt";
in {
  options.${namespace}.programs.sops = with types; {
    enable = mkBoolOpt true "Enable KyleKrein's default sops settings";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [sops];
    sops.defaultSopsFile = ./secrets/secrets.yaml;
    sops.defaultSopsFormat = "yaml";
    sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key" "${impermanence.persistentStorage}/home/kylekrein/.ssh/id_ed25519" "/home/kylekrein/.ssh/id_ed25519"];
    sops.age.keyFile = keyPath;
    # This will generate a new key if the key specified above does not exist
    sops.age.generateKey = true;
  };
}
