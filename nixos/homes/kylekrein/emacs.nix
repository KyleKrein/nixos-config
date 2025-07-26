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
  services.emacs = {
    enable = true;
    package = config.programs.emacs.package;
    startWithUserSession = true;
    client.enable = true;
  };
}
