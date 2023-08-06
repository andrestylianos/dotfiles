{
  config,
  pkgs,
  inputs,
  system,
  ...
}: {
  hostConfig = {
    shell = {
      zsh.enable = true;
      starship.enable = true;
    };
  };
}
