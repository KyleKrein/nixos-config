{
  osConfig,
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; lib.optionals (config.programs.kitty.enable) [kitty-themes];
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.eza = {
    enable = true;
    icons = "always";
  };
  programs.kitty = {
    enable = osConfig.custom.presets.workstation.enable;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 20;
    };
    settings = {
      confirm_os_window_close = 0;
    };
    #shellIntegration.enableFishIntegration = true;
    themeFile = "Catppuccin-Macchiato";
    #Also available: Catppuccin-Frappe Catppuccin-Latte Catppuccin-Macchiato Catppuccin-Mocha
    # See all available kitty themes at: https://github.com/kovidgoyal/kitty-themes/blob/46d9dfe230f315a6a0c62f4687f6b3da20fd05e4/themes.json
  };
}
