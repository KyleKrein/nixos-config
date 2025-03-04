{ config, pkgs, lib, ... }:
{
  hardware = {
	graphics = {
		enable = true;
		extraPackages = with pkgs; [
			nvidia-vaapi-driver
		];
	};
	nvidia = {
		# https://nixos.wiki/wiki/Nvidia
		# Modesetting is required.
    		modesetting.enable = true;

    		# Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    		# Enable this if you have graphical corruption issues or application crashes after waking
    		# up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    		# of just the bare essentials.
   		powerManagement.enable = true;#false;

    		# Fine-grained power management. Turns off GPU when not in use.
    		# Experimental and only works on modern Nvidia GPUs (Turing or newer).
    		powerManagement.finegrained = false;

    		# Use the NVidia open source kernel module (not to be confused with the
    		# independent third-party "nouveau" open source driver).
    		# Support is limited to the Turing and later architectures. Full list of 
    		# supported GPUs is at: 
    		# https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    		# Only available from driver 515.43.04+
    		# Currently alpha-quality/buggy, so false is currently the recommended setting.
    		open = true;

    		# Enable the Nvidia settings menu,
		# accessible via `nvidia-settings`.
    		nvidiaSettings = true;

    		# Optionally, you may need to select the appropriate driver version for your specific GPU.
    		#package = config.boot.kernelPackages.nvidiaPackages.latest;	
	};
		
	logitech.wireless.enable = true;
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.mkDriver { #fixes https://github.com/NixOS/nixpkgs/issues/375730 temporary
      version = "570.86.16"; # use new 570 drivers
      sha256_64bit = "sha256-RWPqS7ZUJH9JEAWlfHLGdqrNlavhaR1xMyzs8lJhy9U=";
      openSha256 = "sha256-DuVNA63+pJ8IB7Tw2gM4HbwlOh1bcDg2AN2mbEU9VPE=";
      settingsSha256 = "sha256-9rtqh64TyhDF5fFAYiWl3oDHzKJqyOW3abpcf2iNRT8=";
      usePersistenced = false;
    };
	
}
