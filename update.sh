#bin/bash

sudo nix flake update --flake .
sudo nixos-rebuild boot --flake ./#homepc --show-trace
