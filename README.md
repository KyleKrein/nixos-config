# NixOS Config

Apply cloned config
```bash
sudo nixos-rebuild switch --flake ~/nixos-config#kylekrein-homepc
```

Rebuild system
```bash
nh os switch
```

Generate hardware report
```bash
sudo nix run \
  --option experimental-features "nix-command flakes" \
  --option extra-substituters https://numtide.cachix.org \
  --option extra-trusted-public-keys numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE= \
  github:numtide/nixos-facter -- -o facter.json
```

## Install system
Assuming that you're in nixos installer
```bash
sudo nix --extra-experimental-features "flakes nix-command" run github:nix-community/disko -- --mode zap_create_mount --flake github:KyleKrein/nixos-config#kylekrein-homepc
```

Copy sops age keys to `/persist/sops/age/keys.txt` or to `/var/lib/sops/age/keys.txt` if not using impermanence

```bash
sudo mkdir /mnt/tmp && TMPDIR=/mnt/tmp sudo nixos-install --flake github:KyleKrein/nixos-config#kylekrein-homepc --no-root-passwd && sudo rm -rf /mnt/tmp
```
