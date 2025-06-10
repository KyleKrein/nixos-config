{ pkgs, inputs,  ...}:
{
  nixpkgs.overlays = [
    inputs.niri-flake.overlays.niri
  ];
  imports = [
    inputs.niri-flake.nixosModules.niri
  ];
  security.pam.services.hyprlock = {};
  systemd.user.extraConfig = '' DefaultEnvironment="PATH=/run/wrappers/bin:/etc/profiles/per-user/%u/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin:$PATH"
  '';
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
