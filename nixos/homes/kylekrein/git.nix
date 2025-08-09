{pkgs, ...}: {
  programs.git = {
    enable = true;
    userName = "Aleksandr Lebedev";
    userEmail = "alex.lebedev2003@icloud.com";
    extraConfig = {
      credential.helper = "manager";
      credential."https://github.com".username = "KyleKrein";
      credential.credentialStore = "plaintext";
    };
  };
}
