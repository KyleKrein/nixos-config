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
      "VMs"
      "Git"
      "nixos-config"
      "blender"
      ".gnupg"
      ".ssh"
      ".emacs.d"
      ".local/share/keyrings"
      ".local/share/direnv"
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
      ".local/share/TelegramDesktop"
      ".config/solaar"
      ".config/kdeconnect"
      ".config/blender"
      ".config/unity3d"
      ".local/share/aspyr-media"
      ".themes"
    ];
    files = [
      ".screenrc"
      #".steampid"
      #".steampath"
    ];
    allowOther = true;
  };
}
