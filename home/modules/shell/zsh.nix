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
    programs.zsh = {
      enable = true;
      # autocd = true;
      dotDir = ".config/zsh";
      enableAutosuggestions = true;
      enableCompletion = true;
      shellAliases = {
        sl = "exa";
        ls = "exa";
        l = "exa -l";
        la = "exa -la";
        ip = "ip --color=auto";
        cat = "bat";
        nvim-run = "nix run ~/coding/andrestylianos/neovim-flake/";
        nvim-develop = "nix develop ~/coding/andrestylianos/neovim-flake/";
      };

      initExtra = ''
        bindkey '^ ' autosuggest-accept
        autopair-init
      '';

      plugins = with pkgs; [
        {
          name = "formarks";
          src = fetchFromGitHub {
            owner = "wfxr";
            repo = "formarks";
            rev = "8abce138218a8e6acd3c8ad2dd52550198625944";
            sha256 = "1wr4ypv2b6a2w9qsia29mb36xf98zjzhp3bq4ix6r3cmra3xij90";
          };
          file = "formarks.plugin.zsh";
        }
        {
          name = "zsh-syntax-highlighting";
          src = fetchFromGitHub {
            owner = "zsh-users";
            repo = "zsh-syntax-highlighting";
            rev = "0.6.0";
            sha256 = "0zmq66dzasmr5pwribyh4kbkk23jxbpdw4rjxx0i7dx8jjp2lzl4";
          };
          file = "zsh-syntax-highlighting.zsh";
        }
        {
          name = "zsh-autopair";
          src = fetchFromGitHub {
            owner = "hlissner";
            repo = "zsh-autopair";
            rev = "34a8bca0c18fcf3ab1561caef9790abffc1d3d49";
            sha256 = "1h0vm2dgrmb8i2pvsgis3lshc5b0ad846836m62y8h3rdb3zmpy1";
          };
          file = "autopair.zsh";
        }
      ];
    };
  };
}
