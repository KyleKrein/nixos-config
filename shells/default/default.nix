{
  pkgs,
  mkShell,
  ...
}:
mkShell {
  packages = with pkgs; [
    deploy-rs
    custom.deploy-rs-online
  ];
}
