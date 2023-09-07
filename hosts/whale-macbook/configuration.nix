args @ {
  pkgs,
  inputs,
  ...
}: {
  hostConfig = {
    shell = {
      default = "zsh";
    };
  };
}
