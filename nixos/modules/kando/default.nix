{ ... }:
let folder = ".config/kando";
in
{
    home.file = {
	#"${folder}/config.json".source = ./config.json;
	"${folder}/menus.json".source = ./menus.json;
    };
}
