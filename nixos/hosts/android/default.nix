{ pkgs, inputs, ... }:
{
    imports = [
	inputs.nixvim.nixosModules.nixvim
    ];
    programs.nixvim = {
	enable = true;
	defaultEditor = true;

	colorschemes.catppuccin.enable = true;
	plugins = {
		lualine.enable = true;
	};

	opts = {
		number = true;
		shiftwidth = 4;
	};
    };
    environment.packages = with pkgs;[
	neovim
	git
	fastfetch

	(pkgs.writeShellScriptBin "droid-switch" ''
	nix-on-droid switch --flake /data/data/com.termux.nix/files/home/nixos-config
	'')
    ];
    
    home-manager = {
	config = ./home.nix;
	useGlobalPkgs = true;
    };

    system.stateVersion = "24.05";
}
