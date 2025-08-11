#https://github.com/nix-community/home-manager/issues/1011
{config, ...}: let
  homeManagerSessionVars = "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh";
in {
  programs.bash.enable = !config.programs.zsh.enable && !config.programs.fish.enable && !config.programs.nushell.enable;
  programs.bash.initExtra = ''
    source "${homeManagerSessionVars}"
  '';
}
