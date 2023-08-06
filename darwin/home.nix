{
  config,
  pkgs,
  lib,
  inputs,
  osConfig,
  ...
}: {
  home.username = "andre";
  home.homeDirectory = "/Users/andre";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.11";

  home.packages = with pkgs; [
    exa
    ripgrep
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
