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
  username = "andrej";
  admin = false;
  extraGroups = ["networkmanager"];
  trustedSshKeys = [];

  cfg = config.${namespace}.users.${username};
in {
  options.${namespace}.users.${username} = with types; {
    enable = mkBoolOpt false "Enable ${username} user";
    config = mkOpt types.attrs {} "Additional home manager config for ${username}";
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
