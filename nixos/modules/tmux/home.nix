{ pkgs, ... }:
{
    programs.tmux = {
	enable = true;
	terminal = "tmux-256color";
	prefix = "C-Space";
	clock24 = true;
	mouse = true;
	keyMode = "vi";
	baseIndex = 1;
	sensibleOnTop = true;
	disableConfirmationPrompt = true;
	plugins = with pkgs.tmuxPlugins; [
	    vim-tmux-navigator
	    {
		plugin = catppuccin;
		extraConfig = ''
		set -g @catppuccin_flavour 'mocha'
		set -g @catppuccin_date_time "%H:%M"
		'';
	    }
	    {
		plugin = resurrect;
		extraConfig = ''
		set -g @resurrect-strategy-vim 'session'
		set -g @resurrect-strategy-nvim 'session'
		set -g @resurrect-capture-pane-contents 'on'
		'';
	    }
	    {
		plugin = continuum;
		extraConfig = ''
		set -g @continuum-restore 'on'
		set -g @continuum-boot 'on'
		set -g @continuum-save-interval '10'
		'';
	    }
	    yank
	];
	extraConfig = ''
	# Shift Alt vim keys to switch windows
	bind -n M-H previous-window
	bind -n M-L next-window
	# Use Alt-arrow keys without prefix key to switch panes
	bind -n M-Left select-pane -L
	bind -n M-Right select-pane -R
	bind -n M-Up select-pane -U
	bind -n M-Down select-pane -D

	# keybindings
	bind-key -T copy-mode-vi v send-keys -X begin-selection
	bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
	bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

	bind '"' split-window -v -c "#{pane_current_path}"
	bind % split-window -h -c "#{pane_current_path}"
	'';
    };
}
