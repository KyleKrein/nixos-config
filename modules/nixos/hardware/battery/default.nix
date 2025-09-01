{
  lib,
  pkgs,
  namespace,
  config,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.hardware.battery;
in {
  options.${namespace}.hardware.battery = with types; {
    enable = mkBoolOpt false "If you have a battery in your hardware, enable this";
    batteryName = mkOpt str "BAT1" ''
      Put your battery name here. You can find it at "/sys/class/power_supply/"
    '';
    remainingEnergy = mkOpt str "charge_now" ''
      File in your battery, that tells the current amount of energy
    '';
    powerUsage = mkOpt str "current_now" ''
      File in your battery, that tells, how much energy your hardware is using
    '';
    scripts = {
      icon = mkOpt' str "";
      status = mkOpt' str "";
      time = mkOpt' str "";
      level = mkOpt' str "";
      labelAdaptive = mkOpt' str "";
      labelPercent = mkOpt' str "";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (import ./batteryStatus.nix {
      inherit config;
      inherit namespace;
      inherit pkgs;
    })
    {
      services.upower.enable = true;
    }
  ]);
}
