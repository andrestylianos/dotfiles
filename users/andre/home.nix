{
  config,
  pkgs,
  lib,
  doom-emacs-src,
  hyprland,
  hyprland-contrib,
  ...
}: let
  my-doom-emacs = let
    emacsPkg = with pkgs;
      (emacsPackagesFor (emacs.override {
        nativeComp = true;
        withPgtk = true;
      }))
      .emacsWithPackages (ps: with ps; [vterm all-the-icons]);
    pathDeps = with pkgs; [
      #python3
      aspell
      binutils
      ripgrep
      fd
      gnutls
      zstd
      shfmt
      shellcheck
      sqlite
      editorconfig-core-c
      gcc
      jq

      nixfmt
    ];
  in
    emacsPkg
    // (pkgs.symlinkJoin {
      name = "my-doom-emacs";
      paths = [emacsPkg];
      nativeBuildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/emacs \
          --prefix PATH : ${lib.makeBinPath pathDeps} \
          --set LSP_USE_PLISTS true
        wrapProgram $out/bin/emacsclient \
          --prefix PATH : ${lib.makeBinPath pathDeps} \
          --set LSP_USE_PLISTS true
      '';
    });
in {
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "andre";
  home.homeDirectory = "/home/andre";

  #nixpkgs.config = {
  #  allowUnfree = true;
  #  packageOverrides = pkgs: {
  #    nur = import (builtins.fetchTarball
  #      "https://github.com/nix-community/NUR/archive/master.tar.gz") {
  #        inherit pkgs;
  #      };
  #  };
  #};

  nixpkgs.overlays = [
    (
      self: super: {
        #slack = super.slack.overrideAttrs (old: {
        #  installPhase =
        #    old.installPhase
        #    + ''
        #      rm $out/bin/slack
        #
        #      makeWrapper $out/lib/slack/slack $out/bin/slack \
        #      --prefix XDG_DATA_DIRS : $GSETTINGS_SCHEMAS_PATH \
        #      --prefix PATH : ${lib.makeBinPath [pkgs.xdg-utils]} \
        #      --add-flags "--ozone-platform-hint=auto --enable-features=WebRTCPipeWireCapturer %U"
        #    '';
        #});
        #waybar = super.waybar.overrideAttrs (oldAttrs: {
        #  mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];
        #});
        waybar = hyprland.packages.${pkgs.hostPlatform.system}.waybar-hyprland;
      }
    )
  ];

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
    sessionPath = ["${config.xdg.configHome}/doom-emacs/bin"];
    sessionVariables = {
      SSH_ASKPASS_REQUIRE = "prefer";
      DOOMDIR = "${config.xdg.configHome}/doom-config";
      DOOMLOCALDIR = "${config.xdg.configHome}/doom-local";
      NIXOS_OZONE_WL = "1";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      MOZ_ENABLE_WAYLAND = "1";
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      SDL_VIDEODRIVER = "wayland";
      XDG_SESSION_TYPE = "wayland";
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

      ".m2/settings.xml".source = ../../config/.m2/settings.xml;
      ".datomic/dev-local.edn".source = ../../config/.datomic/dev-local.edn;
    };
  };

  imports = [
    ./hyprland/config.nix
    ./shell/bin.nix
  ];

  # Use sway desktop environment with Wayland display server
  wayland.windowManager.sway = {
    enable = true;
    systemdIntegration = true;
    xwayland = true;
    wrapperFeatures.gtk = true;
    # Sway-specific Configuration
    extraConfig = ''
      for_window [app_id=".blueman-manager-wrapped"] floating enable, sticky enable, resize set width 580 px height 290 px, move position cursor, move left 5, move down 35
      for_window [app_id="pavucontrol"] floating enable, sticky enable, resize set width 550 px height 600px, move position cursor, move down 35
      for_window [app_id="gnome-calculator"] floating enable
    '';
    config = {
      modifier = "Mod4";
      terminal = "kitty";
      menu = "wofi --show run";
      # Status bar(s)
      bars = [
        {
          fonts.size = 20.0;
          # comment below line for default
          command = "waybar";
          position = "top";
        }
      ];
      assigns = {
        "1: web" = [{class = "Firefox";}];
        "2: work" = [{class = "Brave";}];
        "3: code" = [{class = "Emacs";}];
        "5: comms" = [{class = "Slack";}];
        "0: extra" = [
          {
            class = "Firefox";
            window_role = "About";
          }
        ];
      };
      gaps = {
        outer = 10;
      };
      workspaceAutoBackAndForth = true;
      startup = [
        # Services
        #{ command = "systemctl --user restart kanshi.service"; always = true; }

        # Idle configuration
        {
          command = ''
            swayidle \
              timeout 300 'lock-effects 1' \
              timeout 330 'swaymsg "output * dpms off"' \
              resume 'swaymsg "output * dpms on"' \
              before-sleep 'lock-effects'
          '';
        }

        # Applets
        {command = "blueman-applet";}
      ];
      # Display device configuration
      output = {
        eDP-1 = {
          # Set HIDP scale (pixel integer scaling)
          scale = "2";
        };
        HDMI-A-1 = {
          # Set HIDP scale (pixel integer scaling)
          scale = "2";
        };
      };
    };
    extraSessionCommands = ''
      source /etc/profile
    '';
    swaynag = {
      enable = true;
    };
    # End of Sway-specificc Configuration
  };
  # Bluetooth
  services.blueman-applet.enable = true;

  services.network-manager-applet.enable = true;

  systemd.user.services.sway = {
    Unit = {
      Description = "Sway - Wayland window manager";
      Documentation = ["man:sway(5)"];
      BindsTo = ["graphical-session.target"];
      Wants = ["graphical-session-pre.target"];
      After = ["graphical-session-pre.target"];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.sway}/bin/sway";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  fonts.fontconfig.enable = true;

  programs.bat = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
    #nix-direnv.enableFlakes = true;
  };

  programs.eww-hyprland = {
    enable = true;

    # default package
    package = pkgs.eww-wayland;

    # set to true to reload on change
    autoReload = true;
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

  programs.firefox = {
    enable = true;
    extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      bitwarden
      privacy-badger
      ublock-origin
    ];
    profiles.default = {
      id = 0;
      name = "Default";
      isDefault = true;
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.kitty = {
    enable = true;
  };

  programs.neovim = {
    enable = true;
    package = pkgs.unstable.neovim-unwrapped;
    plugins = with pkgs.unstable.vimPlugins; [
      {
        plugin = leap-nvim;
        config = "lua require('leap').add_default_mappings()";
      }
      {
        plugin = marks-nvim;
        config = "lua require('marks').setup({})";
      }
      {
        plugin = nvim-surround;
        config = "lua require('nvim-surround').setup({})";
      }
      vim-repeat
      vim-sexp
      vim-sexp-mappings-for-regular-people
    ];
    extraConfig = ''
          let mapleader="\<space>"
          let maplocalleader=","

          nmap <localleader>eb <Cmd>call VSCodeNotify('calva.loadFile')<CR>
          nmap <localleader>ed <Cmd>call VSCodeNotify('calva.evaluateCurrentTopLevelForm')<CR>
          nmap <localleader>ee <Cmd>call VSCodeNotify('calva.evaluateSelection')<CR>
          nmap <localleader>ef <Cmd>call VSCodeNotify('calva.evaluateEnclosingForm')<CR>
          nmap <localleader>ei <Cmd>call VSCodeNotify('calva.interruptAllEvaluations')<CR>
          nmap <localleader>rc <Cmd>call VSCodeNotify('calva.connect')<CR>
          nmap <localleader>rr <Cmd>call VSCodeNotify('calva.runCustomREPLCommand', 'r')<CR>
          nmap <localleader>po <Cmd>call VSCodeNotify('calva.runCustomREPLCommand', 'p')<CR>
          nmap <localleader>pc <Cmd>call VSCodeNotify('calva.runCustomREPLCommand', 'k')<CR>
          nmap <localleader>pe <Cmd>call VSCodeNotify('calva.runCustomREPLCommand', 'e')<CR>
          nmap <localleader>pf <Cmd>call VSCodeNotify('calva.runCustomREPLCommand', 'f')<CR>
          nmap <localleader>pd <Cmd>call VSCodeNotify('calva.runCustomREPLCommand', 'd')<CR>
          nmap <localleader>px <Cmd>call VSCodeNotify('calva.runCustomREPLCommand', 'x')<CR>
          nmap <localleader>pi <Cmd>call VSCodeNotify('calva.runCustomREPLCommand', 'q')<CR>
          nmap <localleader>p0 <Cmd>call VSCodeNotify('calva.runCustomREPLCommand', '0')<CR>
          nmap <localleader>p1 <Cmd>call VSCodeNotify('calva.runCustomREPLCommand', '1')<CR>
          nmap <localleader>p2 <Cmd>call VSCodeNotify('calva.runCustomREPLCommand', '2')<CR>
          xmap gc  <Plug>VSCodeCommentary
          nmap gc  <Plug>VSCodeCommentary
          omap gc  <Plug>VSCodeCommentary
          nmap gcc <Plug>VSCodeCommentaryLine

          highlight OperatorSandwichBuns guifg='#aa91a0' gui=underline ctermfg=172 cterm=underline
      highlight OperatorSandwichChange guifg='#edc41f' gui=underline ctermfg='yellow' cterm=underline
      highlight OperatorSandwichAdd guibg='#b1fa87' gui=none ctermbg='green' cterm=none
      highlight OperatorSandwichDelete guibg='#cf5963' gui=none ctermbg='red' cterm=none

          set signcolumn=yes:1
          set shortmess=atOI " No help Uganda information, and overwrite read messages to avoid PRESS ENTER prompts
      set ignorecase     " Case insensitive search
      set smartcase      " ... but case sensitive when uc present
      set scrolljump=5   " Line to scroll when cursor leaves screen
      set scrolloff=3    " Minumum lines to keep above and below cursor
      set nowrap         " Do not wrap long lines
      set shiftwidth=4   " Use indents of 4 spaces
      set tabstop=4      " An indentation every four columns
      set softtabstop=4  " Let backspace delete indent
      set splitright     " Puts new vsplit windows to the right of the current
      set splitbelow     " Puts new split windows to the bottom of the current
      set mousehide      " Hide the mouse cursor while typing
      set hidden         " Allow buffer switching without saving
      set t_Co=256       " Use 256 colors
      set ruler          " Show the ruler
      set showcmd        " Show partial commands in status line and Selected characters/lines in visual mode
      set showmode       " Show current mode in command-line
      set showmatch      " Show matching brackets/parentthesis
      set matchtime=5    " Show matching time
      set report=0       " Always report changed lines
          set linespace=0    " No extra spaces between rows
          set pumheight=20   " Avoid the pop up menu occupying the whole screen
          set fileformats=unix,dos,mac        " Use Unix as the standard file type
          set number                  " Line numbers on

          set whichwrap+=<,>,h,l  " Allow backspace and cursor keys to cross line boundaries

          set termencoding=utf-8
          set fileencoding=utf-8
          set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936

          set wildignore+=*swp,*.class,*.pyc,*.png,*.jpg,*.gif,*.zip
          set wildignore+=*/tmp/*,*.o,*.obj,*.so     " Unix
          set wildignore+=*\\tmp\\*,*.exe            " Windows

          set clipboard=unnamedplus,unnamed

          set undofile             " Persistent undo
          set undolevels=1000      " Maximum number of changes that can be undone
          set undoreload=10000

    '';
  };

  programs.obs-studio = {
    enable = true;
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

  programs.vscode = {
    enable = true;
    package = pkgs.unstable.vscode;
    extensions = with pkgs.unstable.vscode-extensions;
      [
        asvetliakov.vscode-neovim
        betterthantomorrow.calva
        dracula-theme.theme-dracula
        mkhl.direnv
      ]
      ++ pkgs.unstable.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "portal";
          publisher = "djblue";
          version = "0.37.0";
          sha256 = "kn9KCk0rlfF5LKTlidmDVc6VXCm2WKuu12JON0pNpCU=";
        }
        {
          name = "nix-ide";
          publisher = "jnoortheen";
          version = "0.2.1";
          sha256 = "yC4ybThMFA2ncGhp8BYD7IrwYiDU3226hewsRvJYKy4=";
        }
      ];
    keybindings = [
      {
        command = "vscode-neovim.send";
        key = "shift+.";
        when = "editorTextFocus && neovim.mode != insert";
        args = ">";
      }
      {
        command = "vscode-neovim.send";
        key = "shift+,";
        when = "editorTextFocus && neovim.mode != insert";
        args = "<lt>";
      }
      {
        command = "paredit.raiseSexp";
        key = "alt+r";
        when = "editorTextFocus && neovim.mode != insert";
      }
      {
        command = "paredit.spliceSexp";
        key = "alt+shift+2";
        when = "editorTextFocus && neovim.mode != insert";
      }
      {
        command = "paredit.splitSexp";
        key = "alt+s";
        when = "editorTextFocus && neovim.mode != insert";
      }
      {
        command = "paredit.joinSexp";
        key = "alt+j";
        when = "editorTextFocus && neovim.mode != insert";
      }
      {
        command = "paredit.transpose";
        key = "alt+t";
        when = "editorTextFocus && neovim.mode != insert";
      }
      {
        command = "paredit.wrapAroundParens";
        key = "alt+shift+9";
        when = "editorTextFocus && neovim.mode != insert";
      }
      {
        command = "paredit.wrapAroundSquare";
        key = "alt+[";
        when = "editorTextFocus && neovim.mode != insert";
      }
      {
        command = "paredit.wrapAroundCurly";
        key = "alt+shift+[";
        when = "editorTextFocus && neovim.mode != insert";
      }
      {
        command = "paredit.wrapAroundQuote";
        key = "alt+shift+'";
        when = "editorTextFocus && neovim.mode != insert";
      }
      {
        command = "-calva.clearInlineResults";
        key = "escape";
      }
      {
        key = "shift+escape";
        command = "calva.clearInlineResults";
        when = "editorTextFocus && !editorHasMultipleSelections && !editorReadOnly && !hasOtherSuggestions && !suggestWidgetVisible && editorLangId == 'clojure'";
      }
    ];
    userSettings = {
      "workbench.colorTheme" = "Dracula";
      "workbench.editor.highlightModifiedTabs" = true;
      "window.zoomLevel" = -2;
      "editor" = {
        "guides" = {
          "bracketPairs" = true;
          "bracketPairsHorizontal" = true;
        };
        "fontSize" = 18;
        "fontLigatures" = true;
        "fontFamily" = "Fira Code, Menlo, Monaco, 'Courier New', monospace";
        "minimap" = {
          "enabled" = false;
        };
        "accessibilitySupport" = "off";
      };
      "explorer.excludeGitIgnore" = true;
      "files.trimTrailingWhitespace" = true;
      "extensions.experimental.affinity" = {
        "asvetliakov.vscode-neovim" = 1;
      };
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "${pkgs.nil}/bin/nil";
      "nix.serverSettings" = {
        "nil" = {
          "formatting" = {
            "command" = ["alejandra"];
          };
        };
      };
      "extensions.ignoreRecommendations" = true;
      "calva.clojureLspPath" = "${pkgs.clojure-lsp}/bin/clojure-lsp";
      "calva.paredit.defaultKeyMap" = "none";
      "calva.showCalvaSaysOnStart" = false;
      "vscode-neovim.neovimExecutablePaths.linux" = "${config.programs.neovim.finalPackage.outPath}/bin/nvim";
    };
  };

  wayland.windowManager.hyprland.enable = true;

  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        modules-left = [
          "wlr/workspaces"
        #  "wlr/taskbar"
        ];
        modules-center = [  ];
        modules-right = [
          "mpd"
          "idle_inhibitor"
          "pulseaudio"
          "network"
          "cpu"
          "memory"
          "temperature"
          "keyboard-state"
          "clock"
          "tray"
        ];
      };
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

  services.playerctld.enable = true;
  services.emacs = {
    enable = true;
    package = my-doom-emacs;
    client.enable = true;
    socketActivation.enable = true;
  };

  services.gpg-agent = {
    enable = true;
    pinentryFlavor = null;
    extraConfig = ''
      pinentry-program ${pkgs.kwalletcli}/bin/pinentry-kwallet
    '';
  };

  services.swayidle = {
    enable = true;
  };

  services.gnome-keyring.enable = true;

  home.packages = with pkgs; [
    bitwarden
    brave
    cachix
    exa
    git
    git-crypt
    ghostscript
    fd
    flameshot
    fzf
    killall
    my-doom-emacs
    pdfarranger
    kwalletcli

    ripgrep
    fuzzel

    coreutils
    gnutls
    clang

    gnome.nautilus

    # Nix
    nil
    nix-prefetch-github
    alejandra

    # Clojure
    clojure-lsp
    # KDE
    #libsForQt5.bismuth

    # Gnome
    #gnomeExtensions.appindicator
    #gnomeExtensions.pop-shell

    # Work
    unstable.slack

    # Fonts
    (pkgs.nerdfonts.override {fonts = ["FiraCode" "DroidSansMono"];})

    # Compression
    atool
    zip
    unzip
    #tar
    #

    # Sway
    swaylock
    pavucontrol
    # swayidle
    #waybar
    wl-clipboard
    cliphist
    wf-recorder # screen capture
    wlogout # nice gui shutdown menu
    mako
    wofi
    xdg_utils
    xwayland # compatibility layer with XOrg for wayland
    grim # screenshot functionality
    slurp # screenshot functionality
    hyprland-contrib.packages.${pkgs.hostPlatform.system}.grimblast
    playerctl
    #
    ## eww-hyprland
    material-design-icons
    jost
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
        source = doom-emacs-src;
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

      "calva/config.edn" = {
        source = ../../config/calva/config.edn;
      };

      "clojure/deps.edn".source = ../../config/.clojure/deps.edn;

      "gtk-4.0/settings.ini".source = ../../config/gtk-4.0/settings.ini;
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
