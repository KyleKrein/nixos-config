{ pkgs, lib, ... }:
{
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        enable_fingerprint = true;
      };
      background = {
        blur_passes = 1;
        blur_size = 7;
        noise = 0.0117;
        contrast = 0.8916;
        brightness = 0.8172;
        vibrancy = 0.1696;
        vibrancy_darkness = 0.0;
      };
      input-field = {
        size = "600, 100";
        outline_thickness = 3;
        dots_size = 0.33;
        dots_spacing = 0.15;
        dots_center = false;
        dots_rounding = -1;
        dots_fade_time = 200;
        placeholder_text = "<i>Input Password...</i>";
        hide_input = false;
        fade_on_empty = false;
        fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
        fail_timeout = 2000;
        fail_transition = 300;
        position = "0, -20";
        halign = "center";
        valign = "center";
      };
      label = [
        {
          text = "$USER";
          font_family = "Fira Code";
          font_size = 56;
          position = "0, 100";
          halign = "center";
          valign = "center";
        }
        {
          text = "$TIME";
          font_family = "Roboto";
          font_size = 72;
          position = "-40, -40";
          halign = "right";
          valign = "top";
        }
        {
          text = "$LAYOUT";
          font_family = "JetBrains Mono";
          font_size = 28;
          position = "-20, 20";
          halign = "right";
          valign = "bottom";
        }
      ];
    };
  };
}

