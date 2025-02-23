{ pkgs, config, lib, hwconfig, inputs, first-nixos-install, ... }:
let username = "tania";
in
{
    imports = [
    ];
    users.users.${username} = {
	    isNormalUser = true;
	    description = "Tetiana";
	    extraGroups = [ "networkmanager" ];
	    #initialPassword = "1234";
	    hashedPasswordFile = config.sops.secrets."users/${username}".path;
	    packages = with pkgs; [
	    ];
    };
    sops.secrets = {
	"users/${username}" = {
	    neededForUsers = true;
	};
    };

    home-manager.users."${username}" = import ../../home.nix { inherit lib; inherit username; inherit inputs; inherit first-nixos-install; inherit hwconfig; inherit config; inherit pkgs; };
    systemd.tmpfiles.rules = (if hwconfig.useImpermanence then ["d /persist/home/${username} 0700 ${username} users -"] else []); # /persist/home/<user> created, owned by that user
}
