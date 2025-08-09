{
  pkgs,
  lib,
  osConfig,
  ...
}: let
  battery = osConfig.custom.hardware.battery;
  enable = osConfig.custom.windowManagers.niri.enable;
in {
  programs.waybar = {
    inherit enable;
    systemd.enable = true;
    style = ''
      ${builtins.readFile ./waybarstyle.css}'';
    settings = [
      {
        height = 36;
        layer = "top";
        position = "top";
        tray = {spacing = 3;};
        modules-center = [
          "clock"
        ];
        modules-left = [
          "custom/drawer"
          "wlr/taskbar"
          "niri/workspaces"
          "niri/window"
        ];
        modules-right =
          [
            "backlight"
            "pulseaudio"
            #"network"
            #"cpu"
            "memory"
            #"temperature"
            "niri/language"
          ]
          ++ lib.optional battery.enable "custom/battery"
          ++ [
            "tray"
            "custom/notification"
            "custom/power"
          ];
        battery = lib.mkIf battery.enable {
          format = " {time} {icon} ";
          format-alt = " {capacity}% {icon} ";
          format-charging = " {capacity}%  ";
          format-icons = ["" "" "" "" ""];
          format-plugged = " {capacity}%  ";
          states = {
            critical = 10;
            warning = 20;
          };
        };
        backlight = {
          format = "{percent}% 󰛩";
          on-scroll-up = "${pkgs.brightnessctl}/bin/brightnessctl s 5%+";
          on-scroll-down = "${pkgs.brightnessctl}/bin/brightnessctl s 5%-";
        };
        "custom/battery" = {
          exec = "${pkgs.writeShellScriptBin "battery-widget" ''
            ${battery.scripts.labelAdaptive}
            ${battery.scripts.labelPercent}
          ''}/bin/battery-widget";
          interval = 20;
          tooltip = true;
        };
        clock = {
          format = "{:%a %d | %H:%M}";
          format-alt = "{:%d.%m.%Y}";
          tooltip-format = "{:%d.%m.%Y | %H:%M}";
        };
        cpu = {
          format = "{usage}% ";
          tooltip = false;
        };
        "custom/drawer" = {
          format = "<span foreground='white'>󱄅</span>";
          tooltip = false;
          on-click = ''nwg-drawer -fm "dolphin" -closebtn "right" -nocats -term "kitty" -ovl -wm "niri" -s "${./drawerstyle.css}" '';
        };
        "niri/language" = {
          format = "{}";
          format-en = "EN";
          format-ru = "RU";
          format-de = "DE";
          on-click = "niri msg action switch-layout next";
          on-click-right = "niri msg action switch-layout prev";
        };
        "wlr/taskbar" = {
          format = "{icon}";
          icon-size = 18;
          tooltip-format = "{title}";
          on-click = "activate";
          on-click-middle = "close";
        };
        memory = {
          interval = 1;
          format = "  {used}/{total}Gb";
        };
        network = {
          interval = 1;
          format-alt = "{ifname}: {ipaddr}/{cidr}";
          format-disconnected = "Disconnected ⚠";
          format-ethernet = "{ifname}: {ipaddr}/{cidr}   up: {bandwidthUpBits} down: {bandwidthDownBits}";
          format-linked = "{ifname} (No IP) ";
          #format-wifi = "{signalStrength}% ";
          format-wifi = "{signalStrength}%  ";
          tooltip-format = "{essid} ({signalStrength}%) ";
        };
        pulseaudio = {
          format = "{icon} {volume}% {format_source}";
          format-bluetooth = "{icon} {volume}%  {format_source}";
          format-bluetooth-muted = "  {format_source}";
          format-icons = {
            car = "";
            default = [" " " " "  "];
            handsfree = "";
            headphones = "";
            headset = "";
            phone = "";
            portable = "";
          };
          format-muted = " {format_source}";
          format-source = "  {volume}%";
          format-source-muted = "  ";
          on-click = "${pkgs.pwvucontrol}/bin/pwvucontrol";
        };
        "hyprland/submap" = {format = ''<span style="italic">{}</span>'';};
        temperature = {
          critical-threshold = 80;
          format = "{temperatureC}°C {icon}";
          format-icons = ["" "" ""];
        };

        "custom/power" = {
          format = "⏻";
          tooltip = false;
          on-click = "wlogout";
        };

        "custom/notification" = {
          tooltip = false;
          format = "{icon}";
          format-icons = {
            notification = "<span foreground='red'></span>";
            none = "";
            dnd-notification = "<span foreground='red'></span>";
            dnd-none = "";
          };
          return-type = "json";
          exec-if = "which swaync-client";
          exec = "swaync-client -swb";
          on-click = "sleep 0.1 && swaync-client -t -sw";
          on-click-right = "sleep 0.1 && swaync-client -d -sw";
          escape = true;
        };
      }
    ];
  };
}
