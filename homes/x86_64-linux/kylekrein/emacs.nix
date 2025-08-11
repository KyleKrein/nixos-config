{
  pkgs,
  system,
  inputs,
  osConfig,
  lib,
  config,
  ...
}: let
  emacs = pkgs.kylekrein.nixmacs.override {withLsps = true;};
in {
  programs.emacs = {
    enable = osConfig.custom.presets.wayland.enable;
    package = emacs;
  };
  systemd.user.services.emacs = lib.mkIf config.programs.emacs.enable {
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
      Restart = "always";
      RestartSec = 5;
    };
  };
}
