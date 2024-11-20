{
  description = "NixOS config";

  inputs = {
    nixpkgs = {
    	url = "github:nixos/nixpkgs?ref=nixos-unstable";


    };
    hyprland.url = "github:hyprwm/Hyprland";
    stylix.url = "github:danth/stylix";
    nix-flatpak.url = "github:GermanBread/declarative-flatpak/stable-v3";

    #nur.url = "github:nix-community/NUR";

    home-manager = {
	url = "github:nix-community/home-manager";
	inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, stylix, nix-flatpak, ... }@inputs:
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
	  # pkgs = import nixpkgs {
	#	system = x86;
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
	  # pkgs = import nixpkgs {
	#	system = arm;
	 #  };
           modules = [
               	./nixos/configuration.nix
		./nixos/mac-hardware-conf.nix
		./nixos/macos/configuration.nix
	       	inputs.home-manager.nixosModules.default
		stylix.nixosModules.stylix
	   ];
        };
      };
    };
}
