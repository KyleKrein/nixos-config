{
  pkgs,
  mkShell,
  ...
}:
mkShell {
  packages = with pkgs; [
    pkgs.deploy-rs
  ];
}
