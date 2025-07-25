{
  pkgs,
  username,
  lib,
  hwconfig,
  ...
}: {
  imports = [
    (import ./hyprland.nix {
      inherit pkgs;
      inherit lib;
      inherit hwconfig;
      inherit username;
    })
    #../kando
  ];
}
