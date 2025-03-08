{ pkgs, lib,... }:
{
  programs.gnupg.agent = {
    enable = true;
    settings = {
      pinentry-program = lib.mkForce "${pkgs.pinentry-curses}/bin/pinentry-curses";
    };
  };
  environment.systemPackages = with pkgs;[
     (pass.withExtensions (exts: with exts;[
       pass-otp
       pass-import
     ]))
  ];
}
