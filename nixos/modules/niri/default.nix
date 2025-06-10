{ pkgs, inputs,  ...}:
{
  nixpkgs.overlays = [
    inputs.niri-flake.overlays.niri
  ];
  imports = [
    inputs.niri-flake.nixosModules.niri
  ];
  security.pam.services.hyprlock = {};
  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
  };
  niri-flake.cache.enable = true;
  environment.systemPackages = with pkgs;[
    wl-clipboard
    wayland-utils
    libsecret
    gamescope
    xwayland-satellite-stable
    swaybg
  ];
}
