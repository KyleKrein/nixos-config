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
  cfg = config.${namespace}.presets.gaming;
in {
  options.${namespace}.presets.gaming = with types; {
    enable = mkBoolOpt false "Enable everything that you need for gaming";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      unzip
      wget
      xdotool
      xorg.xprop
      xorg.xrandr
      unixtools.xxd
      xorg.xwininfo
      yad
      protonup-qt
      protontricks
    ];
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
      package = pkgs.steam.override {
        extraPkgs = pkgs:
          with pkgs; [
            xorg.libXcursor
            xorg.libXi
            xorg.libXinerama
            xorg.libXScrnSaver
            libpng
            libpulseaudio
            libvorbis
            sdl3
            SDL2
            stdenv.cc.cc.lib
            libkrb5
            keyutils
            gamescope
          ];
      };
    };
    programs.gamemode.enable = true;
  };
}
