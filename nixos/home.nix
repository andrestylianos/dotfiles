{
  config,
  pkgs,
  lib,
  inputs,
  osConfig,
  ...
}: {
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
    sessionVariables = {
      SSH_ASKPASS_REQUIRE = "prefer";
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
    ./shell/bin.nix
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

  services.playerctld.enable = true;
  services.kdeconnect.enable = true;

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
    pdfarranger
    kwalletcli
    discord
    obsidian
    vlc

    neovim

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
    age
    sops
    wl-clipboard
    tldr
  ];

  xdg = {
    enable = true;
    configFile = {
      "clojure/deps.edn".source = ../../config/.clojure/deps.edn;

      "gtk-4.0/settings.ini".source = ../../config/gtk-4.0/settings.ini;
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
