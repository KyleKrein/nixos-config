{ username, inputs, ... }:
{
    imports = [
	inputs.impermanence.nixosModules.home-manager.impermanence
    ];
    home.persistence."/persist/home/${username}" = {
    directories = [
	"Downloads"
	"Music"
	"Pictures"
	"Documents"
	"Videos"
	"VMs"
	"Git"
	"nixos-config"
	"blender"
	".gnupg"
	".ssh"
	".nixops"
	".local/share/keyrings"
	".local/share/direnv"
	{
	    directory = ".local/share/Steam";
	    method = "symlink";
	}
	".mozilla"
	".local/share/TelegramDesktop"
	".config/solaar"
    ];
    files = [
      ".screenrc"
    ];
    allowOther = true;
  };
}
