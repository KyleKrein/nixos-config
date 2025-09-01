{inputs, ...}: final: prev: {
  dgop = inputs.dgop.packages.${prev.system}.dgop;
}
