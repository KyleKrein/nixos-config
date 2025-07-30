{
  config,
  pkgs,
  inputs,
  lib,
  hwconfig,
  ...
}: let
  keyPath =
    if hwconfig.useImpermanence
    then "/persist/sops/age/keys.txt"
    else "/var/lib/sops/age/keys.txt";
in {
  environment.systemPackages = with pkgs; [sops];
  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key" "/home/kylekrein/.ssh/id_ed25519"];
  #sops.age.keyFile = keyPath;
  # This will generate a new key if the key specified above does not exist
  sops.age.generateKey = true;
}
