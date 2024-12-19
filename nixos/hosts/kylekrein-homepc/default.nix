{ pkgs, lib, hwconfig, inputs, ... }:
{
    imports = [
	../../modules/libvirt

	../../users/kylekrein
	(import ../../modules/libvirt/user.nix { username = "kylekrein"; })
    ];
    systemd.network.wait-online.enable = lib.mkForce false;
}
