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
      qt6ct
      libsForQt5.qt5ct
    ];
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

    systemd.user.services.desktop-shell = {
      Unit = {
        Description = "Launches (and relaunches) Desktop Shell";
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
      Service = {
        ExecStart = ''${lib.getExe pkgs.bash} -c "qs -c DankMaterialShell"'';
        Restart = "always";
        RestartSec = 5;
      };
    };

    programs.niri = {
      settings = {
        spawn-at-startup = [
          {command = ["wl-paste" "--watch" "cliphist" "store"];}
        ];
      };
    };
  }
