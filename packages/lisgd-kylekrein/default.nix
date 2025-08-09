{lisgd}:
(lisgd.overrideAttrs
  (final: prev: {
    pname = "lisgd-kylekrein";
    name = "lisgd-kylekrein";
  })).override {conf = ./lisgd-config.h;}
