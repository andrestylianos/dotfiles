{inputs, ...}: final: prev: {
  # use this variant if unfree packages are needed:
  unstable = import inputs.nixpkgs-unstable {
    system = prev.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };
}
