{
  config,
  pkgs,
  inputs,
  system,
  ...
}: {
  hostConfig = {
    cli.enable = true;
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
