{ pkgs, inputs, username, hwconfig, ... }:
{
    environment.systemPackages = with pkgs; [sops];
    sops.defaultSopsFile = ./secrets/secrets.yaml;
    sops.defaultSopsFormat = "yaml";
    sops.age.keyFile = (if hwconfig.useImpermanence then "/persist/sops/age/keys.txt" else "/home/${username}/.config/sops/age/keys.txt");
    # This will generate a new key if the key specified above does not exist
    sops.age.generateKey = true;

    sops.secrets = {
	"users/kylekrein" = {
	    neededForUsers = true;
	};
    };
}
