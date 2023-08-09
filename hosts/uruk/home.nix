{
  config,
  pkgs,
  inputs,
  system,
  ...
}: {
  hostConfig = {
    cli.enable = true;
    desktop = {
      hyprland.enable = true;
    };
    direnv.enable = true;
    editor = {
      emacs.enable = true;
      neovim.enable = true;
    };
    shell = {
      starship.enable = true;
      zsh.enable = true;
    };
  };
}
