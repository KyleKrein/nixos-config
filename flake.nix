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
    #nix-flatpak.url = "github:GermanBread/declarative-flatpak/stable-v3";
    apple-silicon-support.url = "github:tpwrules/nixos-apple-silicon";

    #nur.url = "github:nix-community/NUR";
    sops-nix.url = "github:Mic92/sops-nix";

    home-manager = {
	url = "github:nix-community/home-manager";
	inputs.nixpkgs.follows = "nixpkgs";
    };

     disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    impermanence.url = "github:nix-community/impermanence";
  };

  outputs = { self, nixpkgs, stylix, nixvim, ... }@inputs:
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
       username = "kylekrein";

       general-modules = [
	    inputs.sops-nix.nixosModules.sops
	    inputs.home-manager.nixosModules.default
	    stylix.nixosModules.stylix

       ];

       first-nixos-install = "1729112485"; #stat -c %W /
    in
    {
      nixosConfigurations = {
        "${username}-homepc" = nixpkgs.lib.nixosSystem {
           specialArgs = { 
	    
	    hwconfig = {
		hostname = "${username}-homepc";
		isLaptop = false;
		system = x86;
		useImpermanence = true;
	    };
	    inherit username;
	    inherit first-nixos-install;
	   inherit inputs; };
           
           system = x86;
	  #pkgs = import nixpkgs {
	#	system = x86;
	#	config = {
	#	    allowBroken = true;
	#	    allowUnfree = true;
	#	};
	 #  };
           modules = [
		inputs.impermanence.nixosModules.impermanence
		inputs.disko.nixosModules.default
		(import ./nixos/modules/disko/impermanence-disko.nix { device = "/dev/nvme0n1"; } )
		./nixos/modules/impermanence
	   	#nur.nixosModules.nur
               	./nixos/configuration.nix
		./nixos/nvidia.nix
		./nixos/homepc-hardware-conf.nix
		./nixos/libvirt.nix
		#nix-flatpak.nixosModules.default
	   ] ++ general-modules;
        };
        "${username}-mac" = nixpkgs.lib.nixosSystem {
           specialArgs = { 
	    hwconfig = {
		hostname = "${username}-mac";
		isLaptop = true;
		system = arm;
		useImpermanence = true;
	    };
	    inherit username;
	    inherit first-nixos-install;
	   inherit inputs; };
           
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
		inputs.impermanence.nixosModules.impermanence
		./nixos/mac-hardware-conf.nix
		./nixos/macos/configuration.nix
	   ] ++ general-modules;
        };
      };
    };
}
