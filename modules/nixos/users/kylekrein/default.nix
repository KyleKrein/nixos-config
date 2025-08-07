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
  username = "kylekrein";
  admin = true;
  extraGroups = ["networkmanager" "touchscreen"];
  trustedSshKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGMt3PWVvmEL6a0HHTsxL4KMq1UGKFdzgX5iIkm6owGQ kylekrein@kylekrein-mac"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFDdxZ5OyGcfD1JwEa4RWw86HWZ2dKFR0syrRckl7EvG kylekrein@kylekrein-homepc"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILt+CDDU4gDo12IO2dc50fceIWkn26/NuTq4j25hiGre kylekrein@kylekrein-framework12"
  ];

  cfg = config.${namespace}.users.${username};
in {
  options.${namespace}.users.${username} = with types; {
    enable = mkBoolOpt false "Enable ${username} user";
    config = mkHomeManagerConfigOpt config;
  };

  config = mkUser {
    inherit config;
    inherit (cfg) enable;
    homeConfig = cfg.config;
    inherit username;
    inherit admin;
    inherit extraGroups;
    inherit trustedSshKeys;
  };
}
