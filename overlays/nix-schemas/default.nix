{
  # Channels are named after NixPkgs instances in your flake inputs. For example,
  # with the input `nixpkgs` there will be a channel available at `channels.nixpkgs`.
  # These channels are system-specific instances of NixPkgs that can be used to quickly
  # pull packages into your overlay.
  channels,
  inputs,
  ...
}: final: prev: {
  nix-schemas = inputs.nix-schemas.packages.${prev.system}.nix.overrideAttrs (old: {
    doCheck = false;
    doInstallCheck = false;
    postInstall =
      old.postInstall or ""
      + ''
        mv $out/bin/nix $out/bin/nix-schemas
      '';
  });
}
