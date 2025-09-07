{
  pkgs,
  lib,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    inputs.quickshell.packages.${pkgs.system}.quickshell
    material-symbols
    inter
    fira-code
    cava
    wl-clipboard
    cliphist
    ddcutil
    matugen
    dgop
    glib
    khal # calendar
    gammastep # night mode
    colloid-gtk-theme
    kitty
    playerctl
    brightnessctl
    libnotify
    emacs-pgtk
    hyprshot
    jq
    kdePackages.gwenview
  ];
  home.sessionVariables = {
    GTK_THEME = "Colloid";
  };
  qt.enable = true;
  qt.style.name = "gtk3";
  xdg.configFile."quickshell".source = "${
    inputs.desktopShell.packages.${pkgs.system}.dankMaterialShell
  }/etc/xdg/quickshell";
}
