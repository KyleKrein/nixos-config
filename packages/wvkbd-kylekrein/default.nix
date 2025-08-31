{
  wvkbd,
  fetchFromGitHub,
  lib,
}: let
  smithay-patch = ./wvkbd-smithay.patch; #https://github.com/jjsullivan5196/wvkbd/issues/70
in
  wvkbd.overrideAttrs (final: prev: {
    pname = "wvkbd-kylekrein";
    name = "wvkbd-kylekrein";
    version = "0.17-kylekrein";
    src = fetchFromGitHub {
      owner = "KyleKrein";
      repo = "wvkbd";
      rev = "ed46e1b0e64fd105402dc85e607892343677f5bd";
      hash = "sha256-xhn3QjKJL53K59oSnnLFVEv4AyRUGhYBoqSwJe4qfxE=";
    };
    installFlags = prev.installFlags ++ ["LAYOUT=vistath"];
    patches = prev.patches or [] ++ [smithay-patch];
    meta.mainProgram = "wvkbd";
  })
