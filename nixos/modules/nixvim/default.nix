{ pkgs, inputs, ... }:
{
    imports = [
	inputs.nixvim.homeManagerModules.nixvim
    ];
    
    programs.nixvim = {
	enable = true;
	colorschemes.catppuccin.enable = true;
	plugins = {
	    markview.enable = true;
	    tmux-navigator = {
		enable = true;
	    };
	    cmp = {
		enable = true;
		autoEnableSources = true;
	    };
	    lsp-format = {
		enable = false;
	    };
	    lsp = {
		enable = false;
		inlayHints = true;
		servers = { 
		    nixd = {
          enable = true;
          #extraOptions = {
           # nixos = {
            #  expr = "(builtins.getFlake \"/etc/nixos\").nixosConfigurations.aurelionite.options";
            #};
            #home_manager = {
            #  expr = "(builtins.getFlake \"/etc/nixos\").homeConfigurations.aurelionite.options";
            #};
          #};
        };
		};
	    };
	};
	opts = {
	    number = true;
	    shiftwidth = 4;
	    relativenumber = false;
	};
    };
    
}
