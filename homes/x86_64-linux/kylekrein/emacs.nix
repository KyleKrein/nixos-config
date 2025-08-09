{
  pkgs,
  system,
  inputs,
  ...
}: let
  emacs = inputs.emacs-kylekrein.packages.${system}.with-lsps-native;
in {
  programs.emacs = {
    enable = true;
    package = emacs;
  };
  systemd.user.services.emacs = {
    Unit = {
      Description = "Launches (and relaunches) emacs";
    };
    Install = {
      WantedBy = ["default.target"];
    };
    Service = {
      ExecStart = "${pkgs.writeShellScript "run-emacs" ''
        ${emacs}/bin/emacs --fg-daemon
      ''}";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
