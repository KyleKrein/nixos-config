{
  options,
  config,
  pkgs,
  unstable-pkgs,
  lib,
  hwconfig,
  inputs,
  ...
}: {
  imports = [
    ../../hardware/framework12

    ../../modules/niri

    ../../modules/libvirt

    ../../users/kylekrein
    (import ../../modules/libvirt/user.nix {username = "kylekrein";})

    ../../users/tania

    ./hibernation.nix
  ];

  services.fwupd.enable = true; #fwupdmgr update
  nixpkgs.overlays = [
    # Fixes java crash because of bind mount with impermanence when loading too many mods(ex. All The Mods 9)
    (self: super: {
      prismlauncher = pkgs.symlinkJoin {
        name = "prismlauncher";
        paths = [super.prismlauncher];
        buildInputs = [pkgs.makeWrapper];
        postBuild = ''
          wrapProgram $out/bin/prismlauncher --set HOME /persist/home/kylekrein
        '';
      };
    })
    (self: super: {
      bottles = pkgs.symlinkJoin {
        name = "bottles";
        paths = [super.bottles];
        buildInputs = [pkgs.makeWrapper];
        postBuild = ''
          wrapProgram $out/bin/bottles --set HOME /persist/home/kylekrein
        '';
      };
    })
  ];
  environment.systemPackages = with pkgs; [
    blender
    ladybird
    prismlauncher
  ];

  zramSwap = {
    enable = true; # Hopefully? helps with freezing when using swap
  };
  services.zerotierone = {
    enable = false;
    port = 9994;
    joinNetworks = [
      "A84AC5C10AD269CA"
      "db64858fed285e0f"
    ];
  };
  #LLMs
  services.ollama = {
    enable = true;
    loadModels = ["qwq" "llama3.1" "qwen2.5-coder:7b"];
    home = "/persist/ollama";
    user = "ollama";
    group = "ollama";
  };

  #boot.binfmt.emulatedSystems = ["aarch64-linux" "riscv64-linux"];

  services.open-webui.enable = true;
  #services.open-webui.package = unstable-pkgs.open-webui;
  services.open-webui.openFirewall = false;
  services.open-webui.host = "0.0.0.0";
  services.open-webui.stateDir = "/persist/open-webui";
  systemd.services.open-webui.serviceConfig.User = "ollama";
  systemd.services.open-webui.serviceConfig.Group = "ollama";
  systemd.services.open-webui.serviceConfig.DynamicUser = lib.mkForce false;

  #Chat host
  networking.firewall.allowedTCPPorts = [80 443 22 8448 9993 8081] ++ [config.services.zerotierone.port];
  networking.firewall.allowedUDPPorts = [config.services.zerotierone.port];

  systemd.network.wait-online.enable = lib.mkForce false;
}
