{ pkgs, config, lib, hwconfig, inputs, first-nixos-install, ... }:
let username = "dima";
in
{
    imports = [
    ];
    users.users.${username} = {
	    isNormalUser = true;
	    description = "Dima";
	    extraGroups = [ "networkmanager" ];
	    initialPassword = "1234";
	    #hashedPasswordFile = config.sops.secrets."users/${username}".path;
	    packages = with pkgs; [
	    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILIc/J6YxwWKajJ923/PZ2fcgLgWZdVMcZQ4oZZ+2hwn dima@dragonarch"
    ];

    };
    programs.ssh.forwardX11 = true;
    
    home-manager.users."${username}" = import ../../home.nix { inherit lib; inherit username; inherit inputs; inherit first-nixos-install; inherit hwconfig; inherit config; inherit pkgs; };
    systemd.tmpfiles.rules = (if hwconfig.useImpermanence then ["d /persist/home/${username} 0700 ${username} users -"] else []); # /persist/home/<user> created, owned by that user
}
