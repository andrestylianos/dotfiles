{
  config,
  pkgs,
  lib,
  doom-emacs-src,
  hyprland,
  hyprland-contrib,
  emacs-overlay,
  ...
}: let
  my-doom-emacs = let
    emacsPkg = with pkgs;
      (emacsPackagesFor emacs-overlay.packages.${pkgs.hostPlatform.system}.emacsPgtk)
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
              --set LSP_USE_PLISTS true \
        --set DOOMDIR ${config.xdg.configHome}/doom-config \
        --set DOOMLOCALDIR ${config.xdg.configHome}/doom-local \
        --add-flags "--init-directory ${config.xdg.configHome}/doom-emacs"
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
    };

    pointerCursor = {
      gtk.enable = true;
      package = pkgs.catppuccin-cursors.mochaRed;
      name = "Catppuccin-Mocha-Red-Cursors";
      size = 24;
    };
  };

  imports = [
    ./hyprland/config.nix
    ./shell/bin.nix
    ../../nixos/configuration.nix
  ];

  # Bluetooth
  services.blueman-applet.enable = true;

  services.network-manager-applet.enable = true;

  services.udiskie.enable = true;
  # workaround because udiskie requires this
  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      Requires = ["graphical-session-pre.target"];
    };
  };

  fonts.fontconfig.enable = true;

  programs.bat = {
    enable = true;
  };

  programs.chromium = {
    enable = true;
    extensions = [
      {
        id = "dcpihecpambacapedldabdbpakmachpb";
        updateUrl = "https://djblue.github.io/portal/";
      }
    ];
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
    #nix-direnv.enableFlakes = true;
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
    package = pkgs.firefox-wayland;
    profiles.default = {
      id = 0;
      name = "Default";
      isDefault = true;
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        bitwarden
        privacy-badger
        proton-pass
        ublock-origin
      ];
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrains Mono Regular Nerd Font Complete";
      size = 11;
    };
    extraConfig = ''
      modify_font underline_position +2
      modify_font underline_thickness +1
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
    userSettings = {
      "workbench.colorTheme" = "Default Dark+ Experimental";
      "workbench.editor.highlightModifiedTabs" = true;
      "window.zoomLevel" = -2;
      "editor" = {
        "guides" = {
          "bracketPairs" = true;
          "bracketPairsHorizontal" = true;
        };
        "fontSize" = 20;
        "fontLigatures" = true;
        "fontFamily" = "Iosevka, Fira Code, Menlo, Monaco, 'Courier New', monospace";
        #"fontWeight" = "bold";
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
    };
  };

  wayland.windowManager.hyprland.enable = true;

  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
    systemd = {
      enable = true;
      target = "hyprland-session.target";
    };
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        modules-left = [
          "wlr/workspaces"
          #  "wlr/taskbar"
        ];
        modules-center = [
          "hyprland/window"
          "hyprland/submap"
        ];
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

        "wlr/workspaces" = {
          all-outputs = true;
          on-click = "activate";
        };

        "hyprland/submap" = {
          max-length = 8;
        };

        cpu = {
          format = "{usage}% ";
        };

        memory = {
          format = "{}% ";
        };

        temperature = {
          critical-threshold = 80;
          format = "{temperatureC}°C {icon}";
          format-icons = [
            ""
            ""
            ""
          ];
        };

        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "";
            deactivated = "";
          };
        };
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
      nvim = "nix run github:andrestylianos/neovim-flake";
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

  services.playerctld.enable = true;
  services.kdeconnect.enable = true;

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
    discord
    obsidian
    vlc

    ripgrep
    fuzzel

    coreutils
    gnutls
    clang

    gnome.nautilus

    unstable.flyctl
    # Nix
    nil
    nix-prefetch-github
    alejandra

    # lua
    sumneko-lua-language-server
    stylua

    #neovim
    lazygit
    xclip

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
    (pkgs.nerdfonts.override {fonts = ["FiraCode" "DroidSansMono" "Iosevka" "JetBrainsMono"];})

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

      "clojure/deps.edn".source = ../../config/.clojure/deps.edn;

      "gtk-4.0/settings.ini".source = ../../config/gtk-4.0/settings.ini;
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
