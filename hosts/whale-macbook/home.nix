{
  config,
  pkgs,
  inputs,
  system,
  ...
}: {
  hostConfig = {
    direnv.enable = true;
    editor = {
      neovim.enable = true;
    };
    shell = {
      starship.enable = true;
      zsh.enable = true;
    };
  };
}
