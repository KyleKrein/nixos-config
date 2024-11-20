{ pkgs, lib, ... }:
{
	imports = [
		./apple-silicon-support
	];
	hardware.asahi = {
		peripheralFirmwareDirectory = ./firmware;
		useExperimentalGPUDriver = true;
		setupAsahiSound = true;
	};
	#hardware.graphics.enable32Bit = lib.mkForce false;
	environment.systemPackages = with pkgs; [mesa mesa.drivers];
}
