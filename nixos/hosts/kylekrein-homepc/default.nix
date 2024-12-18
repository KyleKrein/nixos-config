{ pkgs, lib, hwconfig, inputs, ... }:
{
    systemd.network.wait-online.enable = lib.mkForce false;
}
