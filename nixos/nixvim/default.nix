{ pkgs, inputs, ... }:
{
    imports = [
	inputs.nixvim.homeManagerModules.nixvim
    ];
    
    programs.nixvim = {
	enable = true;
	colorschemes.catppuccin.enable = true;
	plugins = {
	    cmp = {
		enable = true;
		autoEnableSources = true;
		settings = {
		sources = [
		    {
            name = "nvim_lsp";
            priority = 1000;
            option = {
              #inherit get_bufnrs;
            };
          }
          {
            name = "nvim_lsp_signature_help";
            priority = 1000;
            option = {
              #inherit get_bufnrs;
            };
          }
          {
            name = "nvim_lsp_document_symbol";
            priority = 1000;
            option = {
             # inherit get_bufnrs;
            };
          }
          {
            name = "treesitter";
            priority = 850;
            option = {
            #  inherit get_bufnrs;
            };
          }
          {
            name = "buffer";
            priority = 500;
            option = {
           #   inherit get_bufnrs;
            };
          }
          {
            name = "path";
            priority = 300;
          }
		]; };
	    };
	    lsp-format = {
		enable = true;
	    };
	    lsp = {
		enable = true;
		inlayHints = true;
		servers = { 
		    nixd = {
          enable = true;
          extraOptions = {
            nixos = {
              expr = "(builtins.getFlake \"/etc/nixos\").nixosConfigurations.aurelionite.options";
            };
            home_manager = {
              expr = "(builtins.getFlake \"/etc/nixos\").homeConfigurations.aurelionite.options";
            };
          };
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
