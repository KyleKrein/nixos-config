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
       #system = "x86_64-linux";
       #pkgs = import nixpkgs {
       #   inherit system;
       #   config = {
       #      allowUnfree = true;	     
       #   };
       #};
    in
    {
      nixosConfigurations = {
        homepc = nixpkgs.lib.nixosSystem {
           specialArgs = { hostname = "nixosbtw"; system = "x86_64-linux"; inherit inputs; };
           
           modules = [
	   	#nur.nixosModules.nur
               	./nixos/configuration.nix
		./nixos/nvidia.nix
		./nixos/homepc-hardware-conf.nix
	       	inputs.home-manager.nixosModules.default
		stylix.nixosModules.stylix
		#nix-flatpak.nixosModules.default
	   ];
        };
        mac = nixpkgs.lib.nixosSystem {
           specialArgs = { hostname = "nixos-macbook-kylekrein"; system = "aarch64-linux"; inherit inputs; };
           
           modules = [
               	./nixos/configuration.nix
		./nixos/mac-hardware-conf.nix
	       	inputs.home-manager.nixosModules.default
		stylix.nixosModules.stylix
	   ];
        };
      };
    };
}
