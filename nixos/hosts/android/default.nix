{ pkgs, ... }:

{
    environment.packages = with pkgs;[
	neovim
	git
	fastfetch
    ];
    
    home-manager.config = (import home.nix);

    system.stateVersion = "24.05";
}
