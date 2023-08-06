{
  config,
  pkgs,
  inputs,
  system,
  ...
}: {
  hostConfig = {
    direnv.enable = true;
    shell = {
      starship.enable = true;
      zsh.enable = true;
    };
  };
}
