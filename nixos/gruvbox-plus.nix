{ pkgs }:

pkgs.stdenv.mkDerivation {
	name = "gruvbox-plus";
	src = pkgs.fetchurl {
		url = "https://github.com/SylEleuth/gruvbox-plus-icon-pack/releases/tag/v5.5.0/gruvbox-plus-icon-pack-5.5.0.zip";
		sha256 = "hDhqR0ynVlJEmpxD5eeCqbYHF1++SgRWmvncqnZ3hE0=";
	};
	dontUnpack = true;
	installPhase = ''
          mkdir -p $out
	  ${pkgs.unzip}/bin/unzip $src -d $out/
	'';
}
