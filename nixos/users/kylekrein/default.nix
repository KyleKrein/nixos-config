{
  pkgs,
  config,
  lib,
  hwconfig,
  inputs,
  first-nixos-install,
  ...
}: let
  username = "kylekrein";
in {
  imports = [
  ];
  users.users.${username} = {
    isNormalUser = true;
    description = "Aleksandr Lebedev";
    extraGroups = ["networkmanager" "wheel"];
    #initialPassword = "1234";
    hashedPasswordFile = config.sops.secrets."users/${username}".path;
    packages = with pkgs; [];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGMt3PWVvmEL6a0HHTsxL4KMq1UGKFdzgX5iIkm6owGQ kylekrein@kylekrein-mac"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFDdxZ5OyGcfD1JwEa4RWw86HWZ2dKFR0syrRckl7EvG kylekrein@kylekrein-homepc"
    ];
  };
  sops.secrets = {
    "users/${username}" = {
      neededForUsers = true;
    };
  };
  nix.settings.trusted-users = [
    "kylekrein"
  ];

  home-manager.users."${username}" = import ../../home.nix {
    inherit lib;
    inherit username;
    inherit inputs;
    inherit first-nixos-install;
    inherit hwconfig;
    inherit config;
    inherit pkgs;
  };
  kylekrein.services.autoUpgrade = {
    #configDir = lib.mkForce "/home/${username}/nixos-config";
    #user = lib.mkForce username;
  };
  programs.nh.flake = lib.mkForce "/home/${username}/nixos-config";
  systemd.tmpfiles.rules =
    if hwconfig.useImpermanence
    then ["d /persist/home/${username} 0700 ${username} users -"]
    else []; # /persist/home/<user> created, owned by that user
}
