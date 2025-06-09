#https://github.com/sodiboo/niri-flake/blob/main/default-config.kdl.nix
#https://github.com/sodiboo/niri-flake/blob/main/docs.md
#https://github.com/sodiboo/system/blob/main/niri.mod.nix
{config, pkgs, lib, inputs, hwconfig, ...}:
{
  programs.fuzzel = {
    enable = true;
    settings.main.terminal = "kitty";
  };
  services.swaync = {
    enable = true;
  };
  imports = [
    ./waybar
  ];
  home.packages = with pkgs;[
    wlogout
    brightnessctl
    fuzzel
    waybar
    swaybg
    libnotify
    swaylock
    networkmanagerapplet
  ];
  programs.niri = {
    settings = {
      outputs = lib.mkIf (hwconfig.hostname == "kylekrein-homepc") {
	"DP-1" = {
	  scale = 1.6;
	  position.x = 1600;
	  position.y = 0;
	};
	"DP-3" = {
	  scale = 1.6;
	  position.x = 0;
	  position.y = 0;
	};
      };
      spawn-at-startup = let
	set-low-brightness = lib.mkIf (hwconfig.isLaptop) {
	  command = [
	    "${lib.getExe pkgs.brightnessctl}"
	    "set"
	    "25%"
	  ];
	};
      in [
	set-low-brightness
	{
          command = [
            "${lib.getExe pkgs.networkmanagerapplet}"
          ];
        }
	{
          command = [
            "${pkgs.solaar}/bin/solaar"
	    "-w"
	    "hide"
          ];
        }
	{
          command = [
            "${lib.getExe pkgs.swaybg}"
            "-m"
            "fill"
            "-i"
            "${../../modules/hyprland/wallpaper.jpg}"
          ];
        }
	{
          command = [
            "emacs"
            "--daemon"
          ];
        }
      ];
      layout = {
        preset-column-widths = [
          {proportion = 1.0 / 3.0;}
          {proportion = 1.0 / 2.0;}
          {proportion = 2.0 / 3.0;}
	  {proportion = 1.0;}
        ];
        default-column-width = {proportion = 1.0 / 3.0;};
      };
      binds = with config.lib.niri.actions; 
  let
	sh = spawn "sh" "-c";
  in {
	"Mod+E".action = sh "emacsclient -c";
	"Mod+T".action = spawn "kitty";
	"Mod+D".action = spawn "fuzzel";
	"Mod+B".action = spawn "librewolf";
	"Mod+H".action = show-hotkey-overlay;
	"Mod+F".action = fullscreen-window;
	"Mod+R".action = switch-preset-column-width;
	"Mod+Q".action = close-window;
	#"Mod+Q".action = ;
	"Mod+Shift+S".action = screenshot;
	"Mod+1".action = focus-workspace 1;
	"Mod+2".action = focus-workspace 2;
	"Mod+3".action = focus-workspace 3;
	"Mod+4".action = focus-workspace 4;
	"Mod+5".action = focus-workspace 5;
	"Mod+6".action = focus-workspace 6;
	"Mod+7".action = focus-workspace 7;
	"Mod+8".action = focus-workspace 8;
	"Mod+9".action = focus-workspace 9;
	"Mod+0".action = focus-workspace 10;
	
	"Mod+Shift+1".action.move-column-to-workspace = 1;
	"Mod+Shift+2".action.move-column-to-workspace = 2;
	"Mod+Shift+3".action.move-column-to-workspace = 3;
	"Mod+Shift+4".action.move-column-to-workspace = 4;
	"Mod+Shift+5".action.move-column-to-workspace = 5;
	"Mod+Shift+6".action.move-column-to-workspace = 6;
	"Mod+Shift+7".action.move-column-to-workspace = 7;
	"Mod+Shift+8".action.move-column-to-workspace = 8;
	"Mod+Shift+9".action.move-column-to-workspace = 9;
	"Mod+Shift+0".action.move-column-to-workspace = 10;
	
	"Mod+Left".action = focus-column-left;
	"Mod+Right".action = focus-column-right;
	"Mod+Up".action = focus-workspace-up;
	"Mod+Down".action = focus-workspace-down;
	"Mod+Shift+Left".action = move-column-left;
	"Mod+Shift+Right".action = move-column-right;
	"Mod+Shift+Up".action = move-column-to-workspace-up;
	"Mod+Shift+Down".action = move-column-to-workspace-down;
	"Mod+Ctrl+Left".action = focus-monitor-left;
	"Mod+Ctrl+Right".action = focus-monitor-right;
	"Mod+Shift+Ctrl+Left".action = move-column-to-monitor-left;
	"Mod+Shift+Ctrl+Right".action = move-column-to-monitor-right;


	"XF86AudioRaiseVolume".action = sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+";
        "XF86AudioLowerVolume".action = sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
        "XF86AudioMute".action = sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";

        "XF86MonBrightnessUp".action = sh "brightnessctl set 10%+";
        "XF86MonBrightnessDown".action = sh "brightnessctl set 10%-";
	#"Mod+Tab".action = focus-window-down-or-column-right;
        #"Mod+Shift+Tab".action = focus-window-up-or-column-left;
	"Mod+Tab".action = toggle-overview;
      };
      input = {
	focus-follows-mouse = {
	  #enable = true;
	};
	warp-mouse-to-focus = true;
	keyboard = {
	  xkb.layout = "us, ru";
	  xkb.options = "grp:lctrl_toggle, ctrl:nocaps" + (if hwconfig.hostname == "kylekrein-mac" then ", altwin:swap_alt_win" else "");
	  track-layout = "window";
	  #numlock = true;
	};
	touchpad = {
	  tap = true;
	  #accel-profile = "adaptive";
	  click-method = "clickfinger";
	};
      };
      cursor = {
	hide-after-inactive-ms = 10000;
      };
      gestures.hot-corners.enable = true;
      prefer-no-csd = true;
      environment = {
        XDG_SESSION_TYPE = "wayland";
        __GL_GSYNC_ALLOWED = "1";
        QT_QPA_PLATFORM = "wayland";
      };
      window-rules = [
	{ #active
	  matches = [
            {
	      is-active = true;
	    }
	  ];
	  opacity = 0.9;
	}
	{ #inactive
	  matches = [
            {
	      is-active = false;
	    }
	  ];
	  opacity = 0.7;
	}
	{ #opaque
	  matches = [
            {
	      app-id = "emacs";
	    }
	    {
	      app-id = "blender";
	    }
	  ];
	  opacity = 1.0;
	}
	{ #app-launcher
	  matches = [
            {
	      title = "emacs-run-launcher";
	    }
	  ];
	  open-floating = true;
	  open-focused = true;
	}
      ];
      debug = lib.mkIf (hwconfig.hostname == "kylekrein-mac") {
	render-drm-device = "/dev/dri/renderD128";
      };
    };
  };

  programs.swaylock = {
    enable = true;
    settings = {
      color = "808080";
      font-size = 24;
      indicator-idle-visible = false;
      indicator-radius = 100;
      line-color = "ffffff";
      show-failed-attempts = true;
    };
  };

  services.swayidle = let 
    locking-script = pkgs.writeShellScript "locking-script" ''
pidof swaylock || "${pkgs.swaylock}/bin/swaylock -fF"
'';
    suspendScript = pkgs.writeShellScript "suspend-script" ''
    # check if any player has status "Playing"
    ${lib.getExe pkgs.playerctl} -a status | ${lib.getExe pkgs.ripgrep} Playing -q
    # only suspend if nothing is playing
    if [ $? == 1 ]; then
       ${pkgs.systemd}/bin/systemctl suspend
    fi
  '';
in{
    enable = true;
    events = [
      {
        event = "before-sleep";
        command = "${locking-script};niri msg action power-off-monitors";
      }
      {
        event = "after-resume";
        command = "niri msg action power-on-monitors";
      }
      {
        event = "lock";
        command = "${locking-script}";
      }
    ];
    timeouts = let 
    secondary = "systemctl suspend";
    in[
      {
        timeout = 30;
        command = "pidof swaylock && ${secondary}";
      }
      {
        timeout = 300;
        command = "${locking-script}";
      }
      {
        timeout = 330;
        command = "pidof swaylock && ${secondary}";
      }
    ];
  };
}
