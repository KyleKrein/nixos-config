{ username, ... }:
{
    users.users.${username}.extraGroups = [ "libvirtd" ];
    home-manager.users.${username} = {
    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = [ "qemu:///system" ];
        uris = [ "qemu:///system" ];
      };
    };
  };
}
