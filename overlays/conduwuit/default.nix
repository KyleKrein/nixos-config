{inputs, ...}: final: prev: {
  conduwuit = inputs.conduwuit.packages.${prev.system}.all-features;
}
