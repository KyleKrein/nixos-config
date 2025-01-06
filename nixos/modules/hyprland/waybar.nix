{ pkgs, lib, hwconfig, ... }:

{
  programs.waybar = {
    enable = true;
    #systemd.enable = true;

      #window#waybar {
       # background: transparent;
        #border-bottom: none;
      #}
      #${builtins.readFile "${pkgs.waybar}/etc/xdg/waybar/style.css"}
    style = ''
      ${builtins.readFile ./waybarstyle.css}
	
      * {
        font-size: 15px;
      }
    '';
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
	"hyprland/workspaces"
#	"hyprland/window"
    ];
      modules-right = [
        "pulseaudio"
        #"network"
        #"cpu"
        #"memory"
        #"temperature"
	"hyprland/language"
      ] ++ (if hwconfig.isLaptop then [ "battery" ] else [ ])
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
      clock = {
        format-alt = "{:%Y-%m-%d}";
        tooltip-format = "{:%Y-%m-%d | %H:%M}";
      };
      cpu = {
        format = "{usage}% ";
        tooltip = false;
      };
      "hyprland/language" = {
    		format = " {}";
      };
      memory = { format = "{}% "; };
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
        format = "{volume}% {icon}  {format_source}";
        format-bluetooth = "{volume}% {icon}   {format_source}";
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
        format-muted = "  {format_source}";
        format-source = "{volume}% ";
        format-source-muted = "";
        on-click = "pavucontrol";
      };
      "hyprland/submap" = { format = ''<span style="italic">{}</span>''; };
      temperature = {
        critical-threshold = 80;
        format = "{temperatureC}°C {icon}";
        format-icons = [ "" "" "" ];
      };

      "hyprland/workspaces" = {
	disable-scroll = true;
	all-outputs = true;
	warp-on-scroll = true;
	format = "{name}{icon}";
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
	format = "⏻ ";
	tooltip = false;
	#menu = "on-click";
	#menu-file = ./power_menu.xml;
	#menu-actions = {
	#	shutdown = "shutdown -h now";
	#	reboot = "reboot";
	#	suspend = "systemctl suspend";
	#	hibernate = "systemctl hibernate";
	#};
        on-click = "wlogout";
      };

      "custom/notification" = {
	tooltip = false;
	format = "{icon}";
	format-icons = {
	notification = " <span foreground='red'><small><sup>⬤</sup></small></span>";
	none = " ";
	dnd-notification = " <span foreground='red'><small><sup>⬤</sup></small></span>";
	dnd-none = "  ";
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
