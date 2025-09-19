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
with lib.custom; {
  imports = lib.snowfall.fs.get-non-default-nix-files ./.;
}
