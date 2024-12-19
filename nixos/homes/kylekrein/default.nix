{ username, ... }:
{
    programs.git = {
	enable = true;
	userName = "Aleksandr Lebedev";
	userEmail = "alex.lebedev2003@icloud.com";
	extraConfig = {
		credential.helper = "manager";#"${pkgs.git.override { withLibsecret = true; }}/bin/git-credential-libsecret";
		credential."https://github.com".username = "KyleKrein";
		credential.credentialStore = "plaintext";
	};
  };

}
