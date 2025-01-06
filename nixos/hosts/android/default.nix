{ pkgs, ... }:

{
    environment.packages = with pkgs;[
	neovim
	git
	fastfetch
    ];
    
    home-manager.config = ./home.nix;

    system.stateVersion = "24.05";
}
