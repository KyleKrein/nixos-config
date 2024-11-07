{ config, pkgs, ... }:

  let
  #nur = import (builtins.fetchTarball {
  # Get the revision by choosing a version from https://github.com/nix-community/NUR/commits/master
  #url = "https://github.com/nix-community/NUR/archive/e7fee426abaf126e6bfb6c84f710f57f0e83491c.tar.gz";
  # Get the hash by running `nix-prefetch-url --unpack <url>` on the above url
 #sha256 = "01wx2il71dnsvviqphpdykr6h0hazf6x28ml7xrpr8fdkg1lvpjs";
#}) pkgs {};

  # gruvboxPlus = import ./gruvbox-plus.nix {inherit pkgs;};
  in
{
  imports =
    [
	./hyprland/hyprland.nix
    ];
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "kylekrein";
  home.homeDirectory = "/home/kylekrein";

  qt = {
	enable = true;
	platformTheme.name = "qtct";
	style.name = "kvantum";
  };
  #xdg.configFile."Kvantum/kvantum.kvconfig".source = (pkgs.formats.ini {}).generate "kvantum.kvconfig" {
#	General.theme = "Catppuccin-Mocha";
 # };
 xdg.configFile = {
    "Kvantum/kvantum.kvconfig".text = ''
      [General]
      theme=catppuccin-mocha
    '';

    # The important bit is here, links the theme directory from the package to a directory under `~/.config`
    # where Kvantum should find it.
    "Kvantum/catppuccin-mocha".source = "${pkgs.catppuccin-kvantum}/share/Kvantum/catppuccin-mocha";
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
  home.packages = with pkgs;[
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
    obs-studio
    vesktop
  ];


  programs.kitty = {
      enable = true;
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
  programs.git = {
	enable = true;
	userName = "Aleksandr Lebedev";
	userEmail = "alex.lebedev2003@icloud.com";
	extraConfig = {
		credential.helper = "${pkgs.git.override { withLibsecret = true; }}/bin/git-credential-libsecret";
	};
  };

  
  #gtk = {
#	  enable = true;
#	  cursorTheme.name = "Bibata-Modern-Ice";
#	  cursorTheme.package = pkgs.bibata-cursors;
#	  theme.package = pkgs.adw-gtk3;
#	  theme.name = "adw-gtk3";
#	  iconTheme.package = gruvboxPlus;
#	  iconTheme.name = "GruvboxPlus";
 # };

  #programs.firefox = {
  #enable = true;
  #profiles."kylekrein".extensions = with nur.repos.rycee.firefox-addons; [
   # ublock-origin
    #darkreader
    #videospeed
    #auto-tab-discard
    #privacy-badger
    #sponsorblock
  #];
  #profiles.default = {
  #  id = 0;
  #  name = "Default";
  #  isDefault = true;
  #};
#};
  
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
