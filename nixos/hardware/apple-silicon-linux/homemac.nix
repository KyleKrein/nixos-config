{pkgs, ...}: {
  programs.firefox.profiles.default.settings = {
    "media.gmp-widevinecdm.version" = pkgs.widevinecdm-aarch64.version;
    "media.gmp-widevinecdm.visible" = true;
    "media.gmp-widevinecdm.enabled" = true;
    "media.gmp-widevinecdm.autoupdate" = false;
    "media.eme.enabled" = true;
    "media.eme.encrypted-media-encryption-scheme.enabled" = true;
  };

  home.file."firefox-widevinecdm" = {
    enable = true;
    target = ".mozilla/firefox/default/gmp-widevinecdm";
    source = pkgs.runCommandLocal "firefox-widevinecdm" {} ''
      out=$out/${pkgs.widevinecdm-aarch64.version}
      mkdir -p $out
      ln -s ${pkgs.widevinecdm-aarch64}/manifest.json $out/manifest.json
      ln -s ${pkgs.widevinecdm-aarch64}/libwidevinecdm.so $out/libwidevinecdm.so
    '';
    recursive = true;
  };
}
