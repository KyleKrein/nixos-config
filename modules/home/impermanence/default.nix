{
  lib,
  osConfig,
  pkgs,
  inputs,
  namespace,
  system,
  target,
  format,
  virtual,
  systems,
  config,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.impermanence;
  osCfg = osConfig.${namespace}.impermanence;
  name = config.snowfallorg.user.name;
  home = config.snowfallorg.user.home.directory;
in {
  options.${namespace}.impermanence = with types; {
    enable = mkBoolOpt osCfg.enable "Enable impermanence";
    persistentStorage = mkOpt path "${osCfg.persistentStorage}${home}" "Actual persistent storage path";
  };

  imports = with inputs; [
    impermanence.homeManagerModules.impermanence
  ];

  config = mkIf cfg.enable {
    home.persistence."${cfg.persistentStorage}" = {
      directories = [
        "Downloads"
        "Music"
        "Pictures"
        "Documents"
        "Videos"
        "Apps"
        "VMs"
        "Git"
        "nixos-config"
        "blender"
        ".gnupg"
        ".password-store"
        ".ssh"
        ".emacs.d"
        ".local/share/keyrings"
        ".local/share/direnv"
        ".local/share/chat.fluffy.fluffychat"
        ".klei"
        "Android"
        {
          directory = ".var/app";
          method = "symlink";
        }
        {
          directory = ".local/share/Steam";
          method = "symlink";
        }
        ".mozilla"
        ".librewolf"
        ".local/share/mcpelauncher"
        ".local/share/PrismLauncher"
        ".local/share/TelegramDesktop"
        ".local/share/Paradox Interactive"
        ".config/unity3d/Ludeon Studios/RimWorld by Ludeon Studios"
        ".config/solaar"
        ".config/eww"
        ".config/kdeconnect"
        ".config/blender"
        ".config/unity3d"
        ".config/Element"
        ".config/GIMP"
        ".cache/nix-index"
        ".local/share/aspyr-media"
        ".themes"
      ];
      files = [
        ".screenrc"
        ".config/kdeglobals"
        ".config/Minecraft Linux Launcher/Minecraft Linux Launcher UI.conf"
      ];
      allowOther = true;
    };
  };
}
