{ pkgs, ... }:
{
 nixpkgs = {
    overlays = [
      (final: prev: {
        firefox = prev.firefox.overrideAttrs (old: {
          buildCommand =
            old.buildCommand
            + ''
              mkdir -p $out/gmp-widevinecdm/system-installed
              ln -s "${pkgs.widevine-cdm}/share/google/chrome/WidevineCdm/_platform_specific/linux_arm64/libwidevinecdm.so" $out/gmp-widevinecdm/system-installed/libwidevinecdm.so
              ln -s "${pkgs.widevine-cdm}/share/google/chrome/WidevineCdm/manifest.json" $out/gmp-widevinecdm/system-installed/manifest.json
              wrapProgram "$oldExe" \
                      --set MOZ_GMP_PATH "$out/gmp-widevinecdm/system-installed"
            '';
        });
	librewolf = prev.librewolf.overrideAttrs (old: {
          buildCommand =
            old.buildCommand
            + ''
              mkdir -p $out/gmp-widevinecdm/system-installed
              ln -s "${pkgs.widevine-cdm}/share/google/chrome/WidevineCdm/_platform_specific/linux_arm64/libwidevinecdm.so" $out/gmp-widevinecdm/system-installed/libwidevinecdm.so
              ln -s "${pkgs.widevine-cdm}/share/google/chrome/WidevineCdm/manifest.json" $out/gmp-widevinecdm/system-installed/manifest.json
              wrapProgram "$oldExe" \
                      --set MOZ_GMP_PATH "$out/gmp-widevinecdm/system-installed"
            '';
        });
    })];
  };
}
