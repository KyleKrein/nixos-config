{
  config,
  lib,
  pkgs,
  hwconfig,
  first-nixos-install,
  username,
  inputs,
  ...
}:
let
in
{
  imports =
    [
      #./modules/fastfetch
      #./modules/tmux/home.nix
    ]
++ lib.optional (lib.strings.hasInfix "kylekrein" hwconfig.hostname) ./modules/fastfetch
    ++ lib.optional (hwconfig.useImpermanence) (
      import ./modules/impermanence/home.nix {
        inherit username;
        inherit inputs;
      }
    )
    ++ lib.optional (config.programs.hyprland.enable) (
      import ./modules/hyprland/home.nix {
        inherit pkgs;
        inherit username;
        inherit inputs;
        inherit hwconfig;
        inherit lib;
      }
    )
    ++ lib.optional (builtins.pathExists ./homes/${username}) (
      import ./homes/${username} { inherit username; }
    );
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = username;
  home.homeDirectory = "/home/${username}";
  stylix = {
    enable = lib.strings.hasInfix "kylekrein" hwconfig.hostname;
  };
  #xdg.configFile."Kvantum/kvantum.kvconfig".source = (pkgs.formats.ini {}).generate "kvantum.kvconfig" {
  #	General.theme = "Catppuccin-Mocha";
  # };
  #xdg.configFile = {
  #   "Kvantum/kvantum.kvconfig".text = ''
  #     [General]
  #     theme=catppuccin-mocha
  #   '';

  # The important bit is here, links the theme directory from the package to a directory under `~/.config`
  # where Kvantum should find it.
  # "Kvantum/catppuccin-mocha".source = "${pkgs.catppuccin-kvantum}/share/Kvantum/catppuccin-mocha";
  #};

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.eza = {
    enable = true;
    icons = "always";
  };

  #xdg.configFile."qt5ct/qt5ct.conf".source = (pkgs.formats.ini {}).generate "kvantum.kvconfig" {
  #	Appearance.icon_theme = "Breeze Dark";
  #  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    #obs-studio
    #vesktop
    #vscode-fhs
  ];

  programs.kitty = {
    enable =  lib.strings.hasInfix "kylekrein" hwconfig.hostname;
    font = {
      #name = "JetBrainsMono Nerd Font";
      #size = 16;
    };
    settings = {
      confirm_os_window_close = 0;
    };
    #shellIntegration.enableFishIntegration = true;
    themeFile = "Catppuccin-Macchiato";
    #Also available: Catppuccin-Frappe Catppuccin-Latte Catppuccin-Macchiato Catppuccin-Mocha
    # See all available kitty themes at: https://github.com/kovidgoyal/kitty-themes/blob/46d9dfe230f315a6a0c62f4687f6b3da20fd05e4/themes.json
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/kylekrein/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
