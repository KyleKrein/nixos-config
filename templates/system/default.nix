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
}: {
  facter.reportPath = ./facter.json;

  # ======================== DO NOT CHANGE THIS ========================
  system.stateVersion = "25.05";
  # ======================== DO NOT CHANGE THIS ========================
}
