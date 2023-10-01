{
  options,
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.hostConfig.cli;
in {
  options.hostConfig.cli = {
    enable = mkEnableOption "cli";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      difftastic
      exa
      fd
      git-cliff
      procs
      ripgrep
      tldr
      zoxide
    ];

    programs.fzf = {
      enable = true;
      enableZshIntegration = config.hostConfig.shell.zsh.enable;
    };
    programs.bat = {
      enable = true;
    };
    programs.zsh = {
      shellAliases = mkIf config.hostConfig.shell.zsh.enable {
        ls = "exa";
        cat = "bat";
      };
      initExtra = ''
        eval "$(zoxide init zsh)"
      '';
    };
    programs.zellij = {
      enable = true;
      enableZshIntegration = config.hostConfig.shell.zsh.enable;
      package = pkgs.unstable.zellij;
    };
  };
}
