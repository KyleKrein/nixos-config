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
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";

    nix-gaming.url = "github:fufexan/nix-gaming";

    impermanence.url = "github:nix-community/impermanence";
  };

  outputs = { self, nixpkgs, ... }@inputs:
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

    first-nixos-install = "1729112485"; #stat -c %W /
      in
      {
	  nixosConfigurations = {
	      "kylekrein-homepc" = nixpkgs.lib.nixosSystem {
		  specialArgs = { 

		      hwconfig = {
			  hostname = "kylekrein-homepc";
			  isLaptop = false;
			  system = x86;
			  useImpermanence = true;
		      };
		      inherit first-nixos-install;
		      inherit inputs; };

		  system = x86;
pkgs = import nixpkgs {
	system = x86;
	overlays = [
        ];
	config = {
	    allowBroken = true;
	    allowUnfree = true;
	};
  };
		  modules = [
			  (import ./nixos/modules/disko/impermanence-disko.nix { device = "/dev/nvme0n1"; } )
			  ./nixos/configuration.nix
#nix-flatpak.nixosModules.default
		  ];
	      };
	      "kylekrein-mac" = nixpkgs.lib.nixosSystem {
		  specialArgs = { 
		      hwconfig = {
			  hostname = "kylekrein-mac";
			  isLaptop = true;
			  system = arm;
			  useImpermanence = true;
		      };
		      inherit first-nixos-install;
		      inherit inputs; };

		  system = arm;
pkgs = import nixpkgs {
	system = arm;
	overlays = [
	    #(import ./nixos/macos/widevine.nix)
	];
	config = {
	    allowBroken = true;
	    allowUnfree = true;
	    allowUnsupportedSystem = true;
	};
 };
		  modules = [
			  ./nixos/configuration.nix
		  ];
	      };
	  };
      };
}
