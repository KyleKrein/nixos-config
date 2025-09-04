{
  lib,
  stdenv,
  fetchFromGitHub,
  gnumake,
  pkg-config,
  wayland-scanner,
  glib,
  wayland,
  cmake,
}:
stdenv.mkDerivation rec {
  pname = "wlr-autorotate";
  version = "unstable-2023-09-18";

  src = fetchFromGitHub {
    owner = "Lassebq";
    repo = "wlr-autorotate";
    rev = "fae02f4e0a9aaf11142d550ce6e7159065ef369c";
    hash = "sha256-wYTtP0Qj4qOinJZ6/kfh/5HHcayF+UwWRPB5kP3SIyU=";
  };
  dontUseCmakeConfigure = true;
  buildPhase = ''
    make all
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp build/wlr-autorotate $out/bin
  '';

  nativeBuildInputs = [
    gnumake
    cmake
    pkg-config
  ];

  buildInputs = [
    glib.dev
    wayland-scanner
    wayland
  ];

  meta = {
    description = "Automatically changes screen orientation in wlroots based compositors based on the state of accelerometer";
    homepage = "https://github.com/Lassebq/wlr-autorotate";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [];
    mainProgram = "wlr-autorotate";
    platforms = lib.platforms.all;
  };
}
