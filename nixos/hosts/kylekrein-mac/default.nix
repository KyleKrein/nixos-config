{
  pkgs,
  lib,
  hwconfig,
  inputs,
  config,
  unstable-pkgs,
  ...
}: {
  imports = [
    inputs.apple-silicon-support.nixosModules.default
    ./mac-hardware-conf.nix
    ../../hardware/apple-silicon-linux

    ../../modules/niri

    ../../users/kylekrein
  ];
  sops.secrets."ssh_keys/${hwconfig.hostname}" = {};
  facter.reportPath = lib.mkForce null; #fails to generate
  boot.binfmt.emulatedSystems = ["x86_64-linux"];
  nix.settings.extra-platforms = config.boot.binfmt.emulatedSystems;

  services.displayManager.sddm = {
    wayland.enable = lib.mkForce false; # black screen
  };
  environment.systemPackages = with pkgs; [
    prismlauncher
    unstable-pkgs.mcpelauncher-ui-qt
  ];
  services.ollama = {
    enable = true;
    loadModels = ["llama3.1" "qwen2.5-coder:7b"];
    home = "/persist/ollama";
    user = "ollama";
    group = "ollama";
  };

  boot = {
    kernelParams = [
      "zswap.enabled=1"
      "zswap.compressor=lzo"
      "zswap.zpool=zsmalloc"
      "zswap.max_pool_percent=50"
    ];
  };

  services.zerotierone = {
    enable = true;
    joinNetworks = [
      "db64858fed285e0f"
    ];
  };
}
