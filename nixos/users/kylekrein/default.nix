{ pkgs, config, lib, hwconfig, inputs, stylix, first-nixos-install, ... }:
let username = "kylekrein";
in
{
    imports = [
    ];
    users.users.${username} = {
	    isNormalUser = true;
	    description = "Aleksandr Lebedev";
	    extraGroups = [ "networkmanager" "wheel" ];
	    #initialPassword = "1234";
	    hashedPasswordFile = config.sops.secrets."users/${username}".path;
	    packages = with pkgs; [];
    };
    sops.secrets = {
	"users/${username}" = {
	    neededForUsers = true;
	};
    };

    home-manager.users."${username}" = import ../../home.nix { inherit username; inherit inputs; inherit stylix; inherit first-nixos-install; inherit hwconfig; inherit config; inherit pkgs; };
    kylekrein.services.autoUpgrade = {
	configDir = lib.mkForce "/home/${username}/nixos-config";
	user = lib.mkForce username;
    };
    programs.nh.flake = lib.mkForce "/home/${username}/nixos-config";
    systemd.tmpfiles.rules = (if hwconfig.useImpermanence then ["d /persist/home/${username} 0700 ${username} users -"] else []); # /persist/home/<user> created, owned by that user
}
