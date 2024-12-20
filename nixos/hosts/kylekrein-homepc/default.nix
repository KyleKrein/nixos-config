{ pkgs, lib, hwconfig, inputs, ... }:
{
    imports = [
	../../hardware/nvidia

	../../modules/hyprland
	
	../../modules/libvirt

	../../users/kylekrein
	(import ../../modules/libvirt/user.nix { username = "kylekrein"; })
	
	../../users/tania
    ];
    
    environment.systemPackages = [
	#inputs.nix-gaming.packages.${pkgs.system}.star-citizen
    ];

    systemd.network.wait-online.enable = lib.mkForce false;
}
