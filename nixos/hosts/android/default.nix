{
  pkgs,
  inputs,
  ...
}: {
  imports = [
  ];
  environment.packages = with pkgs; [
    neovim
    git
    fastfetch
    inputs.neovim.packages.aarch64-linux.default

    (pkgs.writeShellScriptBin "droid-switch" ''
      nix-on-droid switch --flake /data/data/com.termux.nix/files/home/nixos-config
    '')
  ];
  home-manager = {
    config = ./home.nix;
    useGlobalPkgs = true;
  };

  system.stateVersion = "24.05";
}
