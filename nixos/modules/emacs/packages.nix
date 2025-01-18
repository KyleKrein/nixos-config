{
  pkgs,
  emacs,
}: {
  packages = with pkgs; [
    git
    libvterm
    libtool
    emacs
    ripgrep
    fd
    coreutils
    clang
    cmake
    nixfmt-rfc-style
    markdownlint-cli
    pandoc
    gnumake
    python3
    isort
    pipenv
    python313Packages.nose2
    python313Packages.pytest
    graphviz
    shellcheck
    nodejs_23

    (pkgs.writeShellScriptBin "doom-install" ''
      ${pkgs.git}/bin/git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.emacs.d
      ${pkgs.git}/bin/git clone https://github.com/KyleKrein/doomemacs.git ~/.doom.d
      ~/.emacs.d/bin/doom install
      ~/.emacs.d/bin/doom sync
      pidof emacs || ${emacs}/bin/emacs --daemon &
    '')
    (pkgs.writeShellScriptBin "doom-sync" ''
      ~/.emacs.d/bin/doom sync --aot --force
    '')
    (pkgs.writeShellScriptBin "doom-upgrade" ''
      ~/.emacs.d/bin/doom upgrade
    '')
    (pkgs.writeShellScriptBin "doom" ''
      ${emacs}/bin/emacsclient -c -a "${emacs}/bin/emacs"
    '')
  ];
}
