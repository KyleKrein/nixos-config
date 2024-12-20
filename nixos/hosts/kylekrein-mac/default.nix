{ pkgs, lib, hwconfig, inputs, ... }:
{
    imports = [
	inputs.apple-silicon-support.nixosModules.default
	./mac-hardware-conf.nix
	../../hardware/apple-silicon-linux

	../../modules/hyprland

	../../users/kylekrein
    ];
    facter.reportPath = lib.mkForce null; #fails to generate

}
