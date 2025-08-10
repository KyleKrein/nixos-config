{inputs, ...}: final: prev: {
  deploy-rs = inputs.deploy-rs.packages.${prev.system}.deploy-rs;
}
