{
  options,
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.hostConfig.shell.zsh;
in {
  options.hostConfig.shell.zsh = {
    enable = mkEnableOption "zsh shell";
  };

  config = mkIf cfg.enable {
    programs.zsh.enable = true;
    users.users.andre = {
      shell = pkgs.zsh;
    };
  };
}
