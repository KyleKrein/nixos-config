{
  username,
  inputs,
  ...
}: {
  imports = [
    inputs.impermanence.nixosModules.home-manager.impermanence
  ];
  home.persistence."/persist/home/${username}" = {
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
      #{
      #  directory = ".steam";
      #  method = "symlink";
      #}
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
      #".steampid"
      #".steampath"
    ];
    allowOther = true;
  };
}
