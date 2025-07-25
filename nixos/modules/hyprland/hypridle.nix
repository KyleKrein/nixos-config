{
  pkgs,
  lib,
  hwconfig,
  ...
}: let
  suspendScript = pkgs.writeShellScript "suspend-script" ''
    # check if any player has status "Playing"
    ${lib.getExe pkgs.playerctl} -a status | ${lib.getExe pkgs.ripgrep} Playing -q
    # only suspend if nothing is playing
    if [ $? == 1 ]; then
      ${
      if hwconfig.isLaptop
      then "${pkgs.systemd}/bin/systemctl suspend"
      else "loginctl lock-session"
    }
    fi
  '';
in {
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "pidof hyprlock || loginctl lock-session"; # lock before suspend.
        after_sleep_cmd = "hyprctl dispatch dpms on"; # to avoid having to press a key twice to turn on the display.
        ignore_dbus_inhibit = false;
      };

      listener = [
        #{
        #  on-resume="brightnessctl -r"; # monitor backlight restore.
        #  on-timeout="brightnessctl -s set 10"; # set monitor backlight to minimum, avoid 0 on OLED monitor.
        #  timeout=240;
        #}
        #{
        #  on-resume="brightnessctl -rd rgb:kbd_backlight";
        #  on-timeout="brightnessctl -sd rgb:kbd_backlight set 0";
        #  timeout=300;
        #}
        {
          on-timeout = "notify-send \"You're idle. Locking in 30 seconds.\"";
          timeout = 830;
        }
        {
          on-timeout = "pidof hyprlock && systemctl suspend";
          timeout = 120;
        }
        #{
        #  on-timeout="loginctl lock-session";
        #  timeout=360;
        #}
        {
          on-resume = "hyprctl dispatch dpms on";
          on-timeout = suspendScript.outPath;
          timeout = 900;
        }
        #{
        #  on-resume="hyprctl dispatch dpms on"; # screen on when activity is detected after timeout has fired.
        #  on-timeout="hyprctl dispatch dpms off"; # screen off when timeout has passed
        #  timeout=420;
        #}
      ];
    };
  };
}
