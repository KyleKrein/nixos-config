{ pkgs, lib, hwconfig, username, ... }:
let
toggle_monitors = ./toggle_monitors.sh;
wallpaper-image = ./wallpaper.jpg;
in
{
        imports = [
		./waybar.nix
		./hyprlock.nix
		./hypridle.nix
	];
	wayland.windowManager.hyprland = {
		enable = true;
		xwayland.enable = true;
		settings = {
			monitor = if hwconfig.hostname == "kylekrein-homepc" then [
				"DP-1,2560x1440@75,1600x0,1.6"
				"DP-3,2560x1440@75,0x0,1.6"
			] else [",highres,auto,1.6"]
			++
			[
			    "FALLBACK,1920x1080@60,auto,1" #to fix crash on hyprlock https://github.com/hyprwm/hyprlock/issues/434#issuecomment-2341710088
			]
			;

			xwayland = {
				force_zero_scaling = true;
			};

			exec-once = [
				"${if hwconfig.isLaptop then "brightnessctl set 25%" else ""}"
				"dbus-update-activation-environment --systemd --all"
				"${pkgs.waybar}/bin/waybar &"
				"${pkgs.networkmanagerapplet}/bin/nm-applet &"
				"${pkgs.swaynotificationcenter}/bin/swaync &"
				"${pkgs.solaar}/bin/solaar -w hide &"
				#"${pkgs.hypridle}/bin/hypridle &"
				"${pkgs.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1 &" #https://nixos.wiki/wiki/Polkit
				"${pkgs.clipse}/bin/clipse -listen &"
				"${pkgs.swww}/bin/swww-daemon &"
				"${pkgs.swww}/bin/swww img ${wallpaper-image} &"
				"${pkgs.kando}/bin/kando"
			];
			exec = [

				"${pkgs.swww}/bin/swww img ${wallpaper-image} &"
			];
			"$mod" = "SUPER";
			"$mainMod" = "$mod";
			"$terminal" = "${pkgs.kitty}/bin/kitty";
			"$fileManager" = "$terminal ${pkgs.yazi}/bin/yazi";
			"$fileManager2" = "${pkgs.kdePackages.dolphin}/bin/dolphin";
			"$browser" = "${pkgs.firefox}/bin/firefox";
			"$menu" = "${pkgs.wofi}/bin/wofi --show drun";
			"$clipboardManager" = "$terminal --class clipse -e 'clipse'";
			"$makeRegionScreenshot" = "${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp -w 0)\" - | ${pkgs.satty}/bin/satty --early-exit --copy-command 'wl-copy' --filename '-' --initial-tool brush";
			bind = [
				"$mod, T, exec, $terminal"
				"$mod, Q, killactive,"
				"$mod, M, exit,"
				"$mod, B, exec, $browser"
				"$mod SHIFT, V, togglefloating,"
				"$mod, C, exec, $fileManager"
				"$mod SHIFT, C, exec, $fileManager2"
				"$mod, F, fullscreen,"
				"$mod, R, exec, $menu"
				"$mod, V, exec, $clipboardManager"
				"CTRL, SPACE, global, kando:nix-hyprland"
				"$mod SHIFT, I, exec, source ${toggle_monitors}"
				"$mod SHIFT, O, exec, hyprctl dispatch dpms on"
				# Move focus with mainMod + arrow keys
				"$mod, H, movefocus, l"
				"$mod, L, movefocus, r"
				"$mod, K, movefocus, u"
				"$mod, J, movefocus, d"
				# Switch workspaces with mainMod + [0-9]
				"$mainMod, 1, workspace, 1"
				"$mainMod, 2, workspace, 2"
				"$mainMod, 3, workspace, 3"
				"$mainMod, 4, workspace, 4"
				"$mainMod, 5, workspace, 5"
				"$mainMod, 6, workspace, 6"
				"$mainMod, 7, workspace, 7"
				"$mainMod, 8, workspace, 8"
				"$mainMod, 9, workspace, 9"
				"$mainMod, 0, workspace, 10"

				# Move active window to a workspace with mainMod + SHIFT + [0-9]
				"$mainMod SHIFT, 1, movetoworkspace, 1"
				"$mainMod SHIFT, 2, movetoworkspace, 2"
				"$mainMod SHIFT, 3, movetoworkspace, 3"
				"$mainMod SHIFT, 4, movetoworkspace, 4"
				"$mainMod SHIFT, 5, movetoworkspace, 5"
				"$mainMod SHIFT, 6, movetoworkspace, 6"
				"$mainMod SHIFT, 7, movetoworkspace, 7"
				"$mainMod SHIFT, 8, movetoworkspace, 8"
				"$mainMod SHIFT, 9, movetoworkspace, 9"
				"$mainMod SHIFT, 0, movetoworkspace, 10"

				# Swap Windows

				"$mainMod SHIFT, H, swapwindow, l"
				"$mainMod SHIFT, L, swapwindow, r"
				"$mainMod SHIFT, K, swapwindow, u"
				"$mainMod SHIFT, J, swapwindow, d"

				#Resize Windows
				"$mainMod CTRL, H, resizeactive, -50 0"
				"$mainMod CTRL, L, resizeactive, 50 0"
				"$mainMod CTRL, K, resizeactive, 0 -50"
				"$mainMod CTRL, J, resizeactive, 0 50"

				"$mainMod, P, exec, $makeRegionScreenshot"
				"$mainMod ALT, L, exec, ${pkgs.hyprlock}/bin/hyprlock"
			];

			bindm = [
				"$mod, mouse:272, movewindow"
				"$mod, mouse:273, resizewindow"
			];
			input = {
				kb_layout = "us, ru";
				kb_options = "grp:caps_toggle";

				touchpad = {
					natural_scroll = true;
				};
			};
			env = [
				"LIBVA_DRIVER_NAME,nvidia"
				"XDG_SESSION_TYPE,wayland"
				"GBM_BACKEND,nvidia-drm"
				"__GLX_VENDOR_LIBRARY_NAME,nvidia"
				"NVD_BACKEND,direct"
				"XCURSOR_SIZE,24"
				"HYPRCURSOR_SIZE,24"
				"__GL_GSYNC_ALLOWED,1"
				"QT_QPA_PLATFORM,wayland"
				#"QT_QPA_PLATFORMTHEME,kde"
				#"QT_STYLE_OVERRIDE,Breeze"
				#"GDK_SCALE,1.6"
				#"QT_SCALE_FACTOR,1.6"

				"GSK_RENDERER,ngl" #for satty until https://github.com/NixOS/nixpkgs/issues/359069 is fixed
			];

			cursor = {
				no_hardware_cursors = true;
			};

			general = {
				gaps_in = 5;
				gaps_out = 20;
				border_size = 2;

				#"col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
				#"col.inactive_border" = "rgba(595959aa)";
				resize_on_border = false;
				allow_tearing = false;
				layout = "dwindle";

			};

			windowrule = [
				#kando
				"noblur, kando"
				"opaque, kando"
				"size 100% 100%, kando"
				"noborder, kando"
				"noanim, kando"
				"float, kando"
				"pin, kando"

				#blender
				"opaque, blender"
			];

			windowrulev2 = [
				# Ignore maximize requests from apps. You'll probably like this.
				"suppressevent maximize, class:.*"

				# Fix some dragging issues with XWayland
				"nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"

				# Fix for issues with steam
				"stayfocused, title:^()$,class:^(steam)$"
				"minsize 1 1, title:^()$,class:^(steam)$"

				#for clipboard manager
				"float,class:(clipse)"
				"size 622 652,class:(clipse)" # set the size of the window as necessary

			];

			decoration = {
				rounding = 10;

				active_opacity = 0.9;
				inactive_opacity = 0.7;

				#drop_shadow = true;
				#shadow_range = 4;
				#shadow_render_power = 3;
				#"col.shadow" = "rgba(1a1a1aee)";

				blur = {
					enabled = true;
					size = 3;
					passes = 1;

					vibrancy = 0.1696;
				};

			};

			animations = {
				enabled = true;

				bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
				animation = [
					"windows, 1, 7, myBezier"
					"windowsOut, 1, 7, default, popin 80%"
					"border, 1, 10, default"
					"borderangle, 1, 8, default"
					"fade, 1, 7, default"
					"workspaces, 1, 6, default"
				];
			};
		};
	};
}
