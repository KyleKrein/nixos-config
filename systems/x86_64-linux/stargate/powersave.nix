{
  lib,
  pkgs,
  config,
  ...
}: {
  powerManagement.powertop.enable = true;
  environment.systemPackages = with pkgs; [
    powertop
  ];
  services.udev.extraRules = let
    mkRule = as: lib.concatStringsSep ", " as;
    mkRules = rs: lib.concatStringsSep "\n" rs;
  in
    mkRules [
      (mkRule [
        ''ACTION=="add|change"''
        ''SUBSYSTEM=="block"''
        ''KERNEL=="sd[a-z]"''
        ''ATTR{queue/rotational}=="1"''
        ''RUN+="${pkgs.hdparm}/bin/hdparm -B 90 -S ${builtins.toString (30 * 60 / 5)} /dev/%k"''
      ])
    ];
}
