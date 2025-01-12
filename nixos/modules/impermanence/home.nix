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
      ".nixops"
      ".local/share/keyrings"
      ".local/share/direnv"
      {
        directory = ".var/app";
        method = "symlink";
      }
      #{
      #  directory = ".local/share/Steam";
      #  method = "symlink";
      #}
      #".steam"
      ".mozilla"
      ".local/share/TelegramDesktop"
      ".config/solaar"
      ".config/kdeconnect"
      ".config/blender"
    ];
    files = [
      ".screenrc"
    ];
    allowOther = true;
  };
}
