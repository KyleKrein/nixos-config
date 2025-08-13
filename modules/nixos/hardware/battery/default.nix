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

  config = mkIf cfg.enable ((import ./batteryStatus.nix {
      inherit config;
      inherit namespace;
      inherit pkgs;
    })
    // {
      # one of "ignore", "poweroff", "reboot", "halt", "kexec", "suspend", "hibernate", "hybrid-sleep", "suspend-then-hibernate", "lock"
      services.logind.lidSwitch =
        if config.${namespace}.hardware.hibernation.enable
        then "suspend-then-hibernate"
        else "suspend";
      ### NixOS power management
      #https://discourse.nixos.org/t/battery-life-still-isnt-great/41188/7
      powerManagement = {
        enable = true;
        #cpuFreqGovernor = "schedutil";
      };
      services.power-profiles-daemon.enable = false;
      services.auto-cpufreq.enable = true;
      services.auto-cpufreq.settings = {
        battery = {
          governor = "powersave";
          turbo = "never";
        };
        charger = {
          governor = "performance";
          turbo = "auto";
        };
      };

      ### KERNEL
      # boot.kernelParams = [
      #   "ahci.mobile_lpm_policy=3"
      #   "rtc_cmos.use_acpi_alarm=1"
      #];

      ### HWP
      systemd.tmpfiles.rules = [
        "w /sys/devices/system/cpu/cpufreq/policy*/energy_performance_preference - - - - balance_power"
      ];

      ### TLP
      services.tlp = {
        enable = false;
        settings = {
          CPU_SCALING_GOVERNOR_ON_AC = "performance";
          CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

          CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
          CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

          PLATFORM_PROFILE_ON_AC = "performance";
          PLATFORM_PROFILE_ON_BAT = "low-power";

          CPU_BOOST_ON_AC = 1;
          CPU_BOOST_ON_BAT = 0;

          CPU_HWP_DYN_BOOST_ON_AC = 1;
          CPU_HWP_DYN_BOOST_ON_BAT = 0;

          #CPU_MIN_PERF_ON_AC = 0;
          #CPU_MAX_PERF_ON_AC = 100;
          #CPU_MIN_PERF_ON_BAT = 0;
          #CPU_MAX_PERF_ON_BAT = 20;

          #Optional helps save long term battery health
          #START_CHARGE_THRESH_BAT0 = 60; # 60 and below it starts to charge
          #STOP_CHARGE_THRESH_BAT0 = 90; # 90 and above it stops charging
        };
      };

      ### SYSTEM 76 SCHEDULER
      services.system76-scheduler = {
        enable = true;
        useStockConfig = true;
        settings.cfsProfiles.enable = true;
      };
    });
}
