{inputs, ...}: final: prev: {
  conduwuit = prev.matrix-continuwuity; #inputs.conduwuit.packages.${prev.system}.all-features;
}
