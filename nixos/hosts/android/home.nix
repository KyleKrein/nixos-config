{ pkgs, ... }:
{
    imports = [
	#../../modules/nixvim
    ];

    home.stateVersion = "24.05";
}
