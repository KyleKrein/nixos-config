{
  osConfig,
  config,
  pkgs,
  lib,
  inputs,
  namespace,
  ...
}:
with lib.custom; let
  username = config.snowfallorg.user.name;
  home = config.snowfallorg.user.home.directory;
  impermanence = config.${namespace}.impermanence;
in
  lib.mkIf osConfig.custom.windowManagers.niri.enable {
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
    ];
    programs.niri.settings.environment = {
      GTK_THEME = "Colloid";
    };
    qt.enable = true;
    qt.style.name = "gtk3";
    programs.kitty = {
      themeFile = lib.mkForce null;
      extraConfig = ''
        include ${home}/.config/kitty/dank-theme.conf
      '';
    };
    xdg.configFile."quickshell".source = "${
      inputs.desktopShell.packages.${pkgs.system}.dankMaterialShell
    }/etc/xdg/quickshell";
    home.file.".config/DankMaterialShell/settings.json".source = ./settings.json;
    home.persistence = lib.mkIf impermanence.enable {
      "${impermanence.persistentStorage}" = {
        files = [
          ".local/state/DankMaterialShell/session.json"
          ".local/share/color-schemes/DankMatugen.colors"
        ];
        directories = [
          ".config/qt5ct"
          ".config/qt6ct"
          ".config/gtk-3.0"
          ".config/gtk-4.0"
        ];
      };
    };

    programs.niri = {
      settings = {
        spawn-at-startup = [
          {command = ["qs" "-c" "DankMaterialShell"];}
          {command = ["wl-paste" "--watch" "cliphist" "store"];}
        ];
      };
    };
  }
