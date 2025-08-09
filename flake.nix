{
  description = "NixOS config";
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://nix-gaming.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
    ];
  };
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs?ref=nixos-25.05";
    };
    unstable = {
      url = "github:nixos/nixpkgs?ref=nixos-unstable";
    };
    master = {
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
    conduwuit.url = "github:matrix-construct/tuwunel?ref=v1.2.0";
    niri-flake = {
      url = "github:sodiboo/niri-flake";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    lanzaboote.url = "github:nix-community/lanzaboote";

    # The name "snowfall-lib" is required due to how Snowfall Lib processes your
    # flake's inputs.
    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    snowfall-flake = {
      url = "github:snowfallorg/flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-schemas.url = "github:DeterminateSystems/flake-schemas";
    ## nix client with schema support: see https://github.com/NixOS/nix/pull/8892
    nix-schemas = {
      url = "github:DeterminateSystems/nix-src/flake-schemas";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./.;

      channels-config = {
        allowUnfree = true;
      };

      overlays = with inputs; [
        niri-flake.overlays.niri
        snowfall-flake.overlays.default
      ];

      systems.modules.nixos = with inputs; [
        home-manager.nixosModules.home-manager
        nix-flatpak.nixosModules.nix-flatpak
        niri-flake.nixosModules.niri
        sops-nix.nixosModules.sops
        nixos-facter-modules.nixosModules.facter
        home-manager.nixosModules.default
        disko.nixosModules.default
        chaotic.nixosModules.nyx-cache
        chaotic.nixosModules.nyx-overlay
        chaotic.nixosModules.nyx-registry
        lanzaboote.nixosModules.lanzaboote
        impermanence.nixosModules.impermanence
      ];

      systems.hosts.kylekrein-framework12.modules = with inputs; [
        nixos-hardware.nixosModules.framework-12-13th-gen-intel
      ];

      home.modules = with inputs; [
        impermanence.homeManagerModules.impermanence
      ];

      templates = import ./templates {};

      outputs-builder = channels: {
        formatter = channels.nixpkgs.alejandra;
      };

      schemas = inputs.flake-schemas.schemas;

      snowfall = {
        namespace = "custom";
        meta = {
          name = "KyleKrein's awesome Nix Flake";
          title = "KyleKrein's awesome Nix Flake";
        };
      };
    };
}
