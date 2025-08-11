{
  channels,
  namespace,
  inputs,
  lib,
  ...
}: 
  final: prev: let
  inherit (lib.snowfall.fs) get-snowfall-file get-directories get-default-nix-files-recursive;
  inherit (lib.attrsets) nameValuePair listToAttrs;

  srcDir = get-snowfall-file "functions";
  dirs = get-directories srcDir;
  nixFiles =
  lib.concatMap get-default-nix-files-recursive dirs;
  functions = listToAttrs (map
  (file:
    let
      dirName =
        builtins.unsafeDiscardStringContext
          (builtins.baseNameOf
            (builtins.unsafeDiscardStringContext
              (builtins.toString
                (builtins.dirOf file))));
    in
    nameValuePair dirName (final.callPackage file {}))
  nixFiles);
in
functions // {${namespace} = functions;}
