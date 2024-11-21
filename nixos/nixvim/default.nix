{ pkgs, inputs, ... }:
{
    imports = [
	inputs.nixvim.homeManagerModules.nixvim
    ];
    
    programs.nixvim = {
	enable = true;
	colorschemes.catppuccin.enable = true;
	plugins = {

	};
	opts = {
	    number = true;
	    shiftwidth = 4;
	    relativenumber = false;
	};
    };
    
}
