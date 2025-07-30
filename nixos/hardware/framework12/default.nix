{
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.framework-12-13th-gen-intel
  ];
  # Ensure that the `pinctrl_tigerlake` kernel module is loaded before `soc_button_array`.
  # This is required for correcly switching to tablet mode when the display is folded back.
  boot.extraModprobeConfig = ''
    softdep soc_button_array pre: pinctrl_tigerlake
  '';
  # Patch the `udev` rules shipping with `iio-sensor-proxy` according to:
  # https://github.com/FrameworkComputer/linux-docs/blob/main/framework12/Ubuntu-25-04-accel-ubuntu25.04.md
  nixpkgs.overlays = [
    (final: prev: {
      iio-sensor-proxy = prev.iio-sensor-proxy.overrideAttrs (old: {
        postInstall = ''
          ${old.postInstall or ""}
          sed -i 's/.*iio-buffer-accel/#&/' $out/lib/udev/rules.d/80-iio-sensor-proxy.rules
        '';
      });
    })
  ];
  hardware.enableRedistributableFirmware = true;
  environment.systemPackages = [
    pkgs.framework-tool
  ];
  users.groups.touchscreen = {};
  services.udev.extraRules = ''
    KERNEL=="event*", ATTRS{name}=="ILIT2901:00 222A:5539", SYMLINK+="touchscreen", MODE="0660", GROUP="touchscreen"
  '';
}
