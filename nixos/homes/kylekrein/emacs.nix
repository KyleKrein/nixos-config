{
  config,
  hwconfig,
  inputs,
  ...
}: let
  emacs = inputs.emacs-kylekrein.packages.${hwconfig.system}.with-lsps;
in {
  programs.emacs = {
    enable = true;
    package = emacs;
  };
}
