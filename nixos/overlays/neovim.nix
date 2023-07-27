{inputs, ...}: final: prev: {
  neovim = inputs.my-neovim.packages.${prev.stdenv.hostPlatform.system}.default;
}
