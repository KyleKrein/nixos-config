# NixOS Config

Apply cloned config
~~~
sudo nixos-rebuild switch --flake ~/nixos-config#kylekrein-homepc
~~~

Rebuild system
~~~
nh os switch
~~~

## Install system
Assuming that you're in nixos installer
~~~
sudo nix --extra-experimental-features "flakes nix-command" run github:nix-community/disko -- --mode zap_create_mount --flake github:KyleKrein/nixos-config#kylekrein-homepc
~~~

~~~
sudo mkdir /mnt/tmp && TMPDIR=/mnt/tmp sudo nixos-install --flake github:KyleKrein/nixos-config#kylekrein-homepc && sudo rm -rf /mnt/tmp
~~~

or together
~~~
sudo nix --extra-experimental-features "flakes nix-command" run github:nix-community/disko -- --mode zap_create_mount --flake github:KyleKrein/nixos-config#kylekrein-homepc && sudo mkdir /mnt/tmp && TMPDIR=/mnt/tmp sudo nixos-install --flake github:KyleKrein/nixos-config#kylekrein-homepc && sudo rm -rf /mnt/tmp
~~~
