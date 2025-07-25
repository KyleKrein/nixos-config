prev: final: {
  widevinecdm-aarch64 = import ./widevine.nix {
    inherit (final) stdenvNoCC fetchFromGitHub fetchurl python3 squashfsTools nspr;
  };
}
