#nixversion = "24.11";
{
  description = "NixOS config";
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://hyprland.cachix.org"
      "https://nix-gaming.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
    ];
  };
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs?ref=nixos-25.05";
    };
    nixpkgs-unstable = {
      url = "github:nixos/nixpkgs?ref=nixos-unstable";
    };
    nixpkgs-master = {
      url = "github:nixos/nixpkgs?ref=master";
    };
    neovim = {
      url = "github:kylekrein/neovim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    stylix.url = "github:danth/stylix?ref=release-25.05";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    apple-silicon-support.url = "github:nix-community/nixos-apple-silicon";

    sops-nix.url = "github:Mic92/sops-nix";

    home-manager = {
      url = "github:nix-community/home-manager?ref=release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";

    nix-gaming.url = "github:fufexan/nix-gaming";

    impermanence.url = "github:nix-community/impermanence";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    emacs-kylekrein = {
      url = "github:kylekrein/emacs-config";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    beeengine = {
      url = "git+https://github.com/KyleKrein/BeeEngine?submodules=1"; #"git+https://gitlab.kylekrein.com/beeengine/BeeEngine?shallow=1";
    };
    conduwuit.url = "github:matrix-construct/tuwunel";
    niri-flake = {
      url = "github:sodiboo/niri-flake";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    ...
  } @ inputs: let
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
    ladybirdMaster = self: super: { ladybird = super.ladybird.overrideAttrs(old: {
      src = super.fetchFromGitHub {
	owner = "LadybirdWebBrowser";
	repo = "ladybird";
	rev = "71222df4c4103d306fd05b9b0bffb1c1b8e5485e";
	hash = "sha256-hJkK7nag3Z9E8etPFCo0atUEJJnPjjkl7sle/UwkzbE=";
      };
      version = "0-unstable-2025-05-22";
    });};
     nativePackagesOverlay = self: super: {
              stdenv = super.impureUseNativeOptimizations super.stdenv;
            };
    kylekrein-homepc-pkgs = nixpkgs: import nixpkgs {
          system = x86;
          overlays = [
	    inputs.beeengine.overlays.${x86}
	    (final: prev: { #https://github.com/NixOS/nixpkgs/issues/388681
	      pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [(
		python-final: python-prev: {
		  onnxruntime = python-prev.onnxruntime.overridePythonAttrs (
		    oldAttrs: {
		      buildInputs = prev.lib.lists.remove prev.onnxruntime oldAttrs.buildInputs;
		    }
		  );
		}
	      )];
	    })
            #nativePackagesOverlay
	    #ladybirdMaster
          ];
          config = {
            allowBroken = true;
            allowUnfree = true;
            cudaSupport = true;
          };
        };
    kylekrein-server-pkgs = nixpkgs: import nixpkgs {
          system = x86;
          overlays = [
	    (self: super: {
	      conduwuit = inputs.conduwuit.packages."${x86}".all-features;
	    })
            #nativePackagesOverlay
	    #ladybirdMaster
          ];
          config = {
            allowBroken = true;
            allowUnfree = true;
          };
        };
    kylekrein-framework12-pkgs = nixpkgs: import nixpkgs {
      system = x86;
      overlays = [
	inputs.beeengine.overlays.${x86}
      ];
      config = {
        allowBroken = true;
        allowUnfree = true;
      };
    };
    kylekrein-mac-pkgs = nixpkgs: import nixpkgs {
          system = arm;
          overlays = [
	    inputs.beeengine.overlays.${arm}
            #(import ./nixos/macos/widevine.nix)
          ];
          config = {
            allowBroken = true;
            allowUnfree = true;
            allowUnsupportedSystem = true;
           # rocmSupport = true;
          };
        };
        kylekrein-wsl-pkgs = nixpkgs: import nixpkgs {
          system = x86;
          overlays = [
            #nativePackagesOverlay
          ];
          config = {
            allowUnfree = true;
          };
        };
    andrej-pc-pkgs = nixpkgs: import nixpkgs {
          system = x86;
          overlays = [
	    inputs.beeengine.overlays.${x86}
            #nativePackagesOverlay
          ];
          config = {
            #allowBroken = true;
            allowUnfree = true;
            #cudaSupport = true;
          };
        };

    first-nixos-install = "1729112485"; #stat -c %W /
  in {
    nixOnDroidConfigurations.default = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
      pkgs = import nixpkgs {
        system = "aarch64-linux";
        overlays = [inputs.nix-on-droid.overlays.default];
      };
      modules = [./nixos/hosts/android];
      home-manager-path = inputs.home-manager.outPath;
      extraSpecialArgs = {
        inherit inputs;
        inherit first-nixos-install;
      };
    };
    darwinConfigurations = {
      "kylekrein-air" = inputs.nix-darwin.lib.darwinSystem {
        specialArgs = {
          inherit self;
          inherit inputs;
        };
        modules = [./nixos/hosts/kylekrein-air];
      };
    };
    nixosConfigurations = {
      "kylekrein-homepc" = nixpkgs.lib.nixosSystem {
        specialArgs = {
          hwconfig = {
            hostname = "kylekrein-homepc";
            isLaptop = false;
	    hasTouchscreen = false;
            system = x86;
            useImpermanence = true;
          };
          inherit first-nixos-install;
          inherit inputs;
	  unstable-pkgs = kylekrein-homepc-pkgs nixpkgs-unstable;
        };

        system = x86;
        pkgs = kylekrein-homepc-pkgs nixpkgs;
        modules = [
          (import ./disko/impermanence-btrfs.nix {device = "/dev/nvme0n1";})
          ./nixos/configuration.nix
        ];
      };
      "kylekrein-framework12" = nixpkgs.lib.nixosSystem {
        specialArgs = {
          hwconfig = {
            hostname = "kylekrein-framework12";
            isLaptop = true;
	    hasTouchscreen = true;
            system = x86;
            useImpermanence = true;
          };
          inherit first-nixos-install;
          inherit inputs;
	  unstable-pkgs = kylekrein-framework12-pkgs nixpkgs-unstable;
        };

        system = x86;
        pkgs = kylekrein-framework12-pkgs nixpkgs;
        modules = [
          (import ./disko/impermanence-tmpfs-luks.nix {device = "/dev/nvme0n1";})
          ./nixos/configuration.nix
	  inputs.nixos-hardware.nixosModules.framework-12-13th-gen-intel
        ];
      };
      "kylekrein-mac" = nixpkgs.lib.nixosSystem {
        specialArgs = {
          hwconfig = {
            hostname = "kylekrein-mac";
            isLaptop = true;
	    hasTouchscreen = false;
            system = arm;
            useImpermanence = true;
          };
          inherit first-nixos-install;
          inherit inputs;
	  unstable-pkgs = kylekrein-mac-pkgs nixpkgs-unstable;
        };

        system = arm;
        pkgs = kylekrein-mac-pkgs nixpkgs;
        modules = [
          ./nixos/configuration.nix
        ];
      };
      "kylekrein-server" = nixpkgs.lib.nixosSystem {
        specialArgs = {
          hwconfig = {
            hostname = "kylekrein-server";
            isLaptop = false;
	    hasTouchscreen = false;
            system = x86;
            useImpermanence = false;
          };
          inherit first-nixos-install;
          inherit inputs;
	  unstable-pkgs = kylekrein-server-pkgs nixpkgs-unstable;
        };

        system = x86;
        pkgs = kylekrein-server-pkgs nixpkgs;
        modules = [
          ./nixos/hosts/kylekrein-server
        ];
      };
      "kylekrein-wsl" = nixpkgs.lib.nixosSystem {
        specialArgs = {
          hwconfig = {
            hostname = "kylekrein-wsl";
            isLaptop = true;
	    hasTouchscreen = false;
            system = x86;
            useImpermanence = false;
          };
          inherit first-nixos-install;
          inherit inputs;
	  unstable-pkgs = kylekrein-wsl-pkgs nixpkgs-unstable;
        };

        system = x86;
        pkgs = kylekrein-wsl-pkgs nixpkgs;
        modules = [
          inputs.nixos-wsl.nixosModules.default
          ./nixos/wsl.nix
        ];
      };
      "andrej-pc" = nixpkgs.lib.nixosSystem {
        specialArgs = {
          hwconfig = {
            hostname = "andrej-pc";
            isLaptop = false;
	    hasTouchscreen = false;
            system = x86;
            useImpermanence = false;
          };
          inherit first-nixos-install;
          inherit inputs;
	  unstable-pkgs = andrej-pc-pkgs nixpkgs-unstable;
        };

        system = x86;
        pkgs = andrej-pc-pkgs nixpkgs;
        modules = [
          (import ./disko/ext4-swap.nix {device = "/dev/sda"; swapSize = "16G";})
	  (import ./disko/ext4.nix {device = "/dev/sdb";})
          ./nixos/hosts/andrej-pc/configuration.nix
        ];
      };
    };
  };
}
