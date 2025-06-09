{config, username, pkgs, lib, inputs, hwconfig, ...}: {
  imports = [
    ./git.nix
  ] ++ lib.optional (lib.strings.hasInfix "kylekrein" hwconfig.hostname) (
      import ./niri.nix {
        inherit pkgs;
	inherit config;
        inherit username;
        inherit inputs;
        inherit hwconfig;
        inherit lib;
      }
    );
}
