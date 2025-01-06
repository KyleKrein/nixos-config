{
  description = "A neovim configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nvf.url = "github:notashelf/nvf";
  };

  outputs = {
    self,
    nixpkgs,
    nvf,
    ...
  }: {
    packages.x86_64-linux.default =
      (nvf.lib.neovimConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [./nvf-configuration.nix];
      })
      .neovim;
    packages.aarch64-linux.default =
      (nvf.lib.neovimConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-linux;
        modules = [./nvf-configuration.nix];
      })
      .neovim;
    packages.aarch64-darwin.default =
      (nvf.lib.neovimConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        modules = [./nvf-configuration.nix];
      })
      .neovim;
  };
}
