sudo nix-collect-garbage -d && nix-collect-garbage -d && sudo nixos-rebuild switch --flake ./#homepc --show-trace

