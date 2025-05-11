{
  pkgs,
  lib,
  config,
  hwconfig,
  unstable-pkgs,
  ...
}: let
  cfg = config.kk.steam;
  containerPath = if hwconfig.useImpermanence then "/persist/home/containers/steam" else "/var/containers/steam";
  containerName = "fedora-steam";
in {
  options.kk.steam = {
    enable = lib.mkEnableOption "Enable steam";
  };

  config = lib.mkIf cfg.enable (
   if hwconfig.system == "aarch64-linux"
   then {
     virtualisation.podman = {
       enable = true;
       dockerCompat = true;
     };
     environment.systemPackages = with pkgs;[
       distrobox
       (pkgs.writeShellScriptBin "steam-install" ''
    set -e
    echo "Проверяем контейнер Steam..."

    if [ ! -d "${containerPath}" ]; then
        echo "Контейнер не найден, создаем новый с Fedora..."

        # Создаём контейнер с Fedora
	export PATH=${pkgs.podman}/bin:$PATH
        env -u SUDO_USER ${pkgs.distrobox}/bin/distrobox-create --name "${containerName}" --image registry.fedoraproject.org/fedora:latest --home ${containerPath} --hostname ${containerName} --yes

        echo "Контейнер ${containerName} создан, устанавливаем Steam..."
        
        # Устанавливаем Steam внутри контейнера
        env -u SUDO_USER ${pkgs.distrobox}/bin/distrobox-enter "${containerName}" -- sudo dnf upgrade --refresh -y
	env -u SUDO_USER ${pkgs.distrobox}/bin/distrobox-enter "${containerName}" -- sudo dnf copr enable -y @asahi/steam 
	env -u SUDO_USER ${pkgs.distrobox}/bin/distrobox-enter "${containerName}" -- sudo dnf copr enable -y @asahi/fedora-remix-branding
	env -u SUDO_USER ${pkgs.distrobox}/bin/distrobox-enter "${containerName}" -- sudo dnf copr enable -y @asahi/fedora-remix-scripts
	env -u SUDO_USER ${pkgs.distrobox}/bin/distrobox-enter "${containerName}" -- sudo dnf copr enable -y @asahi/kernel
	env -u SUDO_USER ${pkgs.distrobox}/bin/distrobox-enter "${containerName}" -- sudo dnf copr enable -y @asahi/mesa
	env -u SUDO_USER ${pkgs.distrobox}/bin/distrobox-enter "${containerName}" -- sudo dnf copr enable -y @asahi/kernel-edge
	env -u SUDO_USER ${pkgs.distrobox}/bin/distrobox-enter "${containerName}" -- sudo dnf copr enable -y @asahi/packit-builds
	env -u SUDO_USER ${pkgs.distrobox}/bin/distrobox-enter "${containerName}" -- sudo dnf copr enable -y @asahi/u-boot
	env -u SUDO_USER ${pkgs.distrobox}/bin/distrobox-enter "${containerName}" -- sudo dnf copr enable -y @asahi/rawhide-rebuilds
	env -u SUDO_USER ${pkgs.distrobox}/bin/distrobox-enter "${containerName}" -- sudo dnf copr enable -y @asahi/mesa
	env -u SUDO_USER ${pkgs.distrobox}/bin/distrobox-enter "${containerName}" -- sudo dnf copr enable -y @asahi/mesa

env -u SUDO_USER ${pkgs.distrobox}/bin/distrobox-enter "${containerName}" -- sudo dnf upgrade --refresh -y

env -u SUDO_USER ${pkgs.distrobox}/bin/distrobox-enter "${containerName}" -- sudo dnf install --best --setopt=allow_vendor_change=true asahi-repos -y

env -u SUDO_USER ${pkgs.distrobox}/bin/distrobox-enter "${containerName}" -- sudo dnf install --best --setopt=allow_vendor_change=true steam -y
env -u SUDO_USER ${pkgs.distrobox}/bin/distrobox-enter "${containerName}" -- sudo dnf remove dhcpcd -y
    fi

    echo "Экспортируем Steam..."
    env -u SUDO_USER ${pkgs.distrobox}/bin/distrobox enter "${containerName}" -- distrobox-export --app steam
  '')
     ];
     
   }
   else 
    {
      programs.steam = {
        enable = true;#!hwconfig.useImpermanence;
        remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
        dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
        localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
	package = pkgs.steam.override {
      extraPkgs = pkgs: with pkgs; [
        xorg.libXcursor
        xorg.libXi
        xorg.libXinerama
        xorg.libXScrnSaver
        libpng
        libpulseaudio
        libvorbis
        stdenv.cc.cc.lib
        libkrb5
        keyutils
	gamescope
      ];
    };
      };
      programs.gamemode.enable = true;
    }
  );
}
