{
  stdenv,
  gcc,
  writeText,
  lib,
  ...
}:
with lib;
  {
    name,
    code,
    buildInputs ? [],
    cxxFlags ? "-std=c++23 -O2 -Wall",
  }:
    stdenv.mkDerivation {
      pname = name;
      version = "1.0";
      src = writeText "${name}.cpp" code;
      inherit buildInputs;
      nativeBuildInputs = [gcc];

      buildPhase = ''
        mkdir -p build
        $CXX ${cxxFlags} -o ${name} $src \
          ${concatStringsSep " " (map (lib: "-I${lib}/include") buildInputs)} \
          ${concatStringsSep " " (map (lib: "-L${lib}/lib") buildInputs)} \
          ${concatStringsSep " " (map (lib: "-l" + builtins.baseNameOf lib) buildInputs)}
      '';

      dontUnpack = true;

      installPhase = ''
        mkdir -p $out/bin
        cp ${name} $out/bin/
      '';
    }
