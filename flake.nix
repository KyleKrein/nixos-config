{
  description = "NixOS config";

  inputs = {
    nixpkgs = {
    	url = "github:nixos/nixpkgs?ref=nixos-unstable";


    };
    nixvim = {
	url = "github:nix-community/nixvim";
	inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    stylix.url = "github:danth/stylix";
    nix-flatpak.url = "github:GermanBread/declarative-flatpak/stable-v3";
    apple-silicon-support.url = "github:zzywysm/nixos-asahi";

    #nur.url = "github:nix-community/NUR";

    home-manager = {
	url = "github:nix-community/home-manager";
	inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, stylix, nixvim, nix-flatpak, ... }@inputs:
    let
       #systems = ["aarch64-linux" "x86_64-linux" ];
       #forAllSystems = nixpkgs.lib.genAttrs systems;
       #pkgs = import nixpkgs {
       #   inherit system;
       #   config = {
       #      allowUnfree = true;	     
       #   };
       #};
       arm = "aarch64-linux";
       x86 = "x86_64-linux";
    in
    {
      nixosConfigurations = {
        homepc = nixpkgs.lib.nixosSystem {
           specialArgs = { hostname = "nixosbtw"; system = x86; inherit inputs; };
           
           system = x86;
	  #pkgs = import nixpkgs {
	#	system = x86;
	#	config = {
	#	    allowBroken = true;
	#	    allowUnfree = true;
	#	};
	 #  };
           modules = [
	   	#nur.nixosModules.nur
               	./nixos/configuration.nix
		./nixos/nvidia.nix
		./nixos/homepc-hardware-conf.nix
	       	inputs.home-manager.nixosModules.default
		stylix.nixosModules.stylix
		./nixos/libvirt.nix
		#nix-flatpak.nixosModules.default
	   ];
        };
        mac = nixpkgs.lib.nixosSystem {
           specialArgs = { hostname = "nixos-macbook-kylekrein"; system = arm; inherit inputs; };
           system = arm;
	  #pkgs = import nixpkgs {
	#	system = arm;
	#	overlays = [
	#	    (import ./nixos/macos/widevine.nix)
	#	];
	#	config = {
	#	    allowBroken = true;
	#	    allowUnfree = true;
	#	};
	 # };
           modules = [
               	./nixos/configuration.nix
		inputs.apple-silicon-support.nixosModules.default
		./nixos/mac-hardware-conf.nix
		./nixos/macos/configuration.nix
	       	inputs.home-manager.nixosModules.default
		stylix.nixosModules.stylix
	   ];
        };
      };
    };
}
