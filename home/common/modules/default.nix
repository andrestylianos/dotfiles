{...}: {
  imports = [
    ./cli.nix
    ./direnv.nix
    ./editor/emacs
    ./editor/neovim.nix
    ./shell/starship.nix
    ./shell/zsh.nix
  ];
}
