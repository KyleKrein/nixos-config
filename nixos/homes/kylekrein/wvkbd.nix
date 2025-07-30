{
  wvkbd,
  fetchFromGitHub,
  ...
}: let
  niri-patch = ./wvkbd-niri.patch; #https://github.com/jjsullivan5196/wvkbd/issues/70
in
  wvkbd.overrideAttrs (final: prev: {
    version = "0.17";
    src = fetchFromGitHub {
      owner = "Paulicat";
      repo = "wvkbd";
      rev = "ac02545ab6f6ccfa5b6f132414021ba57ea73096";
      hash = "sha256-py/IqNEEaTOx/9W935Vc47WoNFz99+bNaYD0sL//JmY=";
    };
    installFlags = prev.installFlags ++ ["LAYOUT=vistath"];
    patches = prev.patches or [] ++ [niri-patch];
  })
