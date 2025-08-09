{
  config,
  namespace,
  pkgs,
  ...
}: let
  cfg = config.${namespace}.hardware.battery;
  battery-path = "/sys/class/power_supply/${cfg.batteryName}";
  get-battery-level = "${pkgs.writeShellScriptBin "get-battery-level" ''
    cat ${battery-path}/capacity 2>/dev/null || echo "N/A"
  ''}/bin/get-battery-level";
  get-status = "${pkgs.writeShellScriptBin "get-status" ''
    cat ${battery-path}/status 2>/dev/null || echo "Unknown"
  ''}/bin/get-status";
  get-icon = "${pkgs.writeShellScriptBin "get-icon" ''
    BATTERY_LEVEL=$(${get-battery-level})
    STATUS=$(${get-status})
    if [[ "$BATTERY_LEVEL" == "N/A" ]]; then
        ICON="󰂑 "
    elif [[ "$STATUS" == "Charging" ]]; then
        if [[ $BATTERY_LEVEL -ge 90 ]]; then
            ICON="󰂋 "
        elif [[ $BATTERY_LEVEL -ge 80 ]]; then
            ICON="󰂊 "
        elif [[ $BATTERY_LEVEL -ge 70 ]]; then
            ICON="󰢞 "
        elif [[ $BATTERY_LEVEL -ge 60 ]]; then
            ICON="󰂉 "
        elif [[ $BATTERY_LEVEL -ge 50 ]]; then
            ICON="󰢝 "
        elif [[ $BATTERY_LEVEL -ge 40 ]]; then
            ICON="󰂈 "
        elif [[ $BATTERY_LEVEL -ge 30 ]]; then
            ICON="󰂇 "
        elif [[ $BATTERY_LEVEL -ge 20 ]]; then
            ICON="󰂆 "
        elif [[ $BATTERY_LEVEL -ge 10 ]]; then
            ICON="󰢜 "
        else
            ICON="󰢜 "
        fi
    else
        if [[ $BATTERY_LEVEL -ge 90 ]]; then
            ICON="󰂂 "
        elif [[ $BATTERY_LEVEL -ge 70 ]]; then
            ICON="󰂀 "
        elif [[ $BATTERY_LEVEL -ge 50 ]]; then
            ICON="󰁾 "
        elif [[ $BATTERY_LEVEL -ge 30 ]]; then
            ICON="󰁼 "
        elif [[ $BATTERY_LEVEL -ge 10 ]]; then
            ICON="󰁺 "
        else
            ICON="󰁺 "
        fi
    fi

    echo "$ICON"
  ''}/bin/get-icon";
  get-remaining-time = "${pkgs.writeShellScriptBin "get-remaining-time" ''
    REMAINING_ENERGY=$(cat ${battery-path}/${cfg.remainingEnergy})
    POWER_USAGE=$(cat ${battery-path}/${cfg.powerUsage})
    if [[ -n "$REMAINING_ENERGY" && -n "$POWER_USAGE" && "$POWER_USAGE" -ne 0 ]]; then
        TIME_LEFT=$(((REMAINING_ENERGY / POWER_USAGE)))
        MINUTES_LEFT=$(((( (REMAINING_ENERGY * 60) / POWER_USAGE )) - (TIME_LEFT * 60)))
        echo "$TIME_LEFT h $MINUTES_LEFT min"
    else
        echo ""
    fi
  ''}/bin/get-remaining-time";
in {
  ${namespace}.hardware.battery.scripts = {
    icon = get-icon;
    status = get-status;
    time = get-remaining-time;
    level = get-battery-level;
    labelAdaptive = "${pkgs.writeShellScriptBin "labelAdaptive" ''
      if [[ "$(${get-status})" == "Charging" ]]; then
         echo "$(${get-battery-level})% $(${get-icon})"
      else
        echo "$(${get-remaining-time}) $(${get-icon})"
      fi
    ''}/bin/labelAdaptive";
    labelPercent = "${pkgs.writeShellScriptBin "labelPercent" ''
      echo "$(${get-battery-level})% $(${get-icon})"
    ''}/bin/labelPercent";
  };
}
