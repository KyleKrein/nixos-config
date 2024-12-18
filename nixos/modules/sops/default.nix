{ config, pkgs, inputs, username, lib, hwconfig, ... }:
let
    keyPath = (if hwconfig.useImpermanence then "/persist/sops/age/keys.txt" else "/var/lib/sops/age/keys.txt");
in
{
    environment.systemPackages = with pkgs; [sops];
    sops.defaultSopsFile = ./secrets/secrets.yaml;
    sops.defaultSopsFormat = "yaml";
    sops.age.keyFile = keyPath;
    # This will generate a new key if the key specified above does not exist
    sops.age.generateKey = true;

    sops.secrets = {
	"users/kylekrein" = {
	    neededForUsers = true;
	};
    };
    users.users.${username} = {
	hashedPasswordFile = config.sops.secrets."users/${username}".path;
	initialPassword = lib.mkForce null;
    };
}
