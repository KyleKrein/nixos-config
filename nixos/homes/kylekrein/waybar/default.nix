{ pkgs, lib, hwconfig, ... }:
let 
battery = (import ../battery-status.nix {inherit pkgs; inherit hwconfig;});
in
{
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    #window#waybar {
      # background: transparent;
      #border-bottom: none;
      #}
      #${builtins.readFile "${pkgs.waybar}/etc/xdg/waybar/style.css"}
      style = ''
${builtins.readFile ./waybarstyle.css}'';
      settings = [{
        height = 36;
        layer = "top";
        position = "top";
        tray = { spacing = 3; };
        modules-center = [ 
      	#"hyprland/window" 
		    "clock"
	      ];
        modules-left = [ 
	  "custom/drawer"
	  "wlr/taskbar"
	  "niri/workspaces"
        	"niri/window"
        ];
        modules-right = lib.optional hwconfig.isLaptop "backlight"
	  ++ [
          "pulseaudio"
          #"network"
          #"cpu"
          "memory"
          #"temperature"
	    "niri/language"
        ] ++ lib.optional battery.available "custom/battery"
        ++ [
          "tray"
	        "custom/notification"
	        #"custom/disablehypridle"
	        "custom/power"
        ];
        battery = {
          format = " {time} {icon} ";
          format-alt = " {capacity}% {icon} ";
          format-charging = " {capacity}%  ";
          format-icons = [ "" "" "" "" "" ];
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
          exec ="${pkgs.writeShellScriptBin "battery-widget" ''
            ${battery.labelAdaptive}
            ${battery.labelPercent}
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
          format-bluetooth = "{icon} {volume}%   {format_source}";
          format-bluetooth-muted = "  {icon}   {format_source}";
          format-icons = {
            car = "";
            default = [ "" "" "" ];
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
        "hyprland/submap" = { format = ''<span style="italic">{}</span>''; };
        temperature = {
          critical-threshold = 80;
          format = "{temperatureC}°C {icon}";
          format-icons = [ "" "" "" ];
        };

        "hyprland/workspaces" = {
	        disable-scroll = true;
	        all-outputs = false;
	        warp-on-scroll = true;
	        format = "{name}{icon} ";
	        format-icons = {
		        urgent = "";
		        active = "";
		        default = "";
	        };
	        #persistent-workspaces = {
	          #	"*" = 3;
	          #};
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

        "custom/disablehypridle" = {
          exec = ''
            if pgrep -x "hypridle" > /dev/null; then
            echo "{\"text\": \"  \", \"tooltip\": \"Hypridle is running\", \"class\": \"active\"}";
            else
            echo "{\"text\": \"  \", \"tooltip\": \"Hypridle is not running\", \"class\": \"inactive\"}";
            fi
          '';
          return-type = "json";
          on-click = ''
            if pgrep -x "hypridle" > /dev/null; then
            pkill hypridle
            else
            hypridle &
            fi
          '';
        };
      }];
  };
}
