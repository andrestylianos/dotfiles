{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "andre";
  home.homeDirectory = "/home/andre";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.11";

  home = {
    sessionPath = [ "${config.xdg.configHome}/doom-emacs/bin" ];
    sessionVariables = {
      DOOMDIR = "${config.xdg.configHome}/doom-config";
      DOOMLOCALDIR = "${config.xdg.configHome}/doom-local";
    };

    file = { 
      ".emacs-profiles.el".text = ''
        (("default" . ((user-emacs-directory . "${config.xdg.configHome}/my-emacs")))
         ("doom" . ((user-emacs-directory . "${config.xdg.configHome}/doom-emacs")
                    (env . (("DOOMDIR" . "${config.home.sessionVariables.DOOMDIR}")
                            ("DOOMLOCALDIR" . "${config.home.sessionVariables.DOOMLOCALDIR}"))))))
      '';
      ".emacs-profile".text = "doom";
      
      ".emacs.d".source = pkgs.fetchFromGitHub {
        owner = "plexus";
        repo = "chemacs2";
        rev = "c2d700b784c793cc82131ef86323801b8d6e67bb";
        sha256 = "/WtacZPr45lurS0hv+W8UGzsXY3RujkU5oGGGqjqG0Q=";
      };
    };
  };

  fonts.fontconfig.enable = true;

  programs.bat = {
    enable = true;
  };

  programs.emacs = {
    enable = true;
    package = pkgs.emacs;  # replace with pkgs.emacs-gtk, or a version provided by the community overlay if desired.
  };

  programs.git = {
    enable = true;
    userName = "André Stylianos Ramos";
    userEmail = "andre.stylianos@protonmail.com";
    extraConfig = {
      user = {
        signingkey = "A6DDF756C510CB4E";
      };
      commit = {
        gpgsign = true;
      };
    };
  };

  programs.gpg = {
    enable = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.starship = {
    enable = true;
    # Configuration written to ~/.config/starship.toml
    settings = {
      # add_newline = false;

      # character = {
      #   success_symbol = "[➜](bold green)";
      #   error_symbol = "[➜](bold red)";
      # };

      # package.disabled = true;
    };
  };

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

  services.emacs.enable = true;

  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "qt";
  };

  home.packages = with pkgs; [
    atool
    exa
    git
    git-crypt
    gnupg
    fd
    fzf
    killall
    nix-prefetch-github
    pinentry-qt
    ripgrep
    (pkgs.nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })

binutils
    gnutls
  ];

  xdg = {
    enable = true;
    configFile = {
      "doom-config/config.el" = {
        source = ../../config/.doom.d/config.el;
      };
      "doom-config/init.el" = { 
        source = ../../config/.doom.d/init.el;
        onChange = "${pkgs.writeShellScript "doom-init-change" ''
          export DOOMDIR="${config.home.sessionVariables.DOOMDIR}"
          export DOOMLOCALDIR="${config.home.sessionVariables.DOOMLOCALDIR}"
          export PATH=$PATH:$HOME/.nix-profile/bin
          ${config.xdg.configHome}/doom-emacs/bin/doom --force sync
        ''}";
      };       
      "doom-config/packages.el" = { 
        source = ../../config/.doom.d/packages.el;
        onChange = "${pkgs.writeShellScript "doom-packages-change" ''
          export DOOMDIR="${config.home.sessionVariables.DOOMDIR}"
          export DOOMLOCALDIR="${config.home.sessionVariables.DOOMLOCALDIR}"
          export PATH=$PATH:$HOME/.nix-profile/bin
          ${config.xdg.configHome}/doom-emacs/bin/doom --force sync
        ''}";
      };
      "doom-emacs" = {
        source = builtins.fetchGit "https://github.com/doomemacs/doomemacs";
        onChange = "${pkgs.writeShellScript "doom-change" ''
          export DOOMDIR="${config.home.sessionVariables.DOOMDIR}"
          export DOOMLOCALDIR="${config.home.sessionVariables.DOOMLOCALDIR}"
          export PATH=$PATH:$HOME/.nix-profile/bin
          if [ ! -d "$DOOMLOCALDIR" ]; then
            ${config.xdg.configHome}/doom-emacs/bin/doom --force install
          else
            ${config.xdg.configHome}/doom-emacs/bin/doom --force clean
            ${config.xdg.configHome}/doom-emacs/bin/doom --force sync -u
          fi
        ''}";
      };

      "gtk-4.0/settings.ini".source = ../../config/gtk-4.0/settings.ini;
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
