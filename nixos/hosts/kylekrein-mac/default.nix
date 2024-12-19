{ pkgs, lib, hwconfig, inputs, ... }:
{
    imports = [
	inputs.apple-silicon-support.nixosModules.default
	./mac-hardware-conf.nix
	../../hardware/macos/configuration.nix



	../../users/kylekrein
    ];
    facter.reportPath = lib.mkForce null; #fails to generate

}
