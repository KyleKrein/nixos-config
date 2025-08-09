{
  # Channels are named after NixPkgs instances in your flake inputs. For example,
  # with the input `nixpkgs` there will be a channel available at `channels.nixpkgs`.
  # These channels are system-specific instances of NixPkgs that can be used to quickly
  # pull packages into your overlay.
  channels,
  namespace,
  inputs,
  ...
}: final: prev: {
  # For example, to pull a package from unstable NixPkgs
  inherit (channels.unstable) chromium;

  my-package = inputs.my-input.packages.${prev.system}.my-package;
}
