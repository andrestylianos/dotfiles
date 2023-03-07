{ config, pkgs, lib, doom-emacs-src, ... }:

let
  my-doom-emacs = let
    emacsPkg = with pkgs;
      (emacsPackagesFor (emacs.override {
        nativeComp = true;
        withPgtk = true;
      })).emacsWithPackages (ps: with ps; [ vterm all-the-icons ]);
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
  in emacsPkg // (pkgs.symlinkJoin {
    name = "my-doom-emacs";
    paths = [ emacsPkg ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
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

  nixpkgs.overlays = [(
    self: super: {
      slack  = super.slack.overrideAttrs (old: {
        installPhase = old.installPhase + ''
          rm $out/bin/slack

          makeWrapper $out/lib/slack/slack $out/bin/slack \
          --prefix XDG_DATA_DIRS : $GSETTINGS_SCHEMAS_PATH \
          --prefix PATH : ${lib.makeBinPath [pkgs.xdg-utils]} \
          --add-flags "--ozone-platform-hint=auto --enable-features=WebRTCPipeWireCapturer %U"
        '';
      });
    }
  )];

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
      NIXOS_OZONE_WL = "1";
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
      ".clojure/deps.edn".source = ../../config/.clojure/deps.edn;
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
      bars = [{
        fonts.size = 20.0;
        # comment below line for default
        command = "waybar";
        position = "top";
      }];
      assigns = {
        "1: web" = [{ class = "Firefox"; }];
        "2: work" = [{ class = "Brave"; }];
        "3: code" = [{ class = "Emacs"; }];
        "5: comms" = [{ class = "Slack"; }];
        "0: extra" = [{ class = "Firefox"; window_role = "About"; }];
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
        { command = "blueman-applet"; }

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
      Documentation = [ "man:sway(5)" ];
      BindsTo = [ "graphical-session.target" ];
      Wants = [ "graphical-session-pre.target" ];
      After = [ "graphical-session-pre.target" ];
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

  wayland.windowManager.hyprland.enable = true;

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
    pinentryFlavor = "qt";
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
    gnupg
    fd
    flameshot
    fzf
    killall
    my-doom-emacs
    nix-prefetch-github
    pdfarranger
    pinentry-qt
    ripgrep

    coreutils
    gnutls
    clang

    # KDE
    #libsForQt5.bismuth

    # Gnome
    gnomeExtensions.appindicator
    gnomeExtensions.pop-shell

    # Work
    slack

    # Fonts
    (pkgs.nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })

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
    waybar
    wl-clipboard
    wf-recorder # screen capture
    wlogout # nice gui shutdown menu
    mako
    wofi
    xdg_utils
    xwayland # compatibility layer with XOrg for wayland
    grim # screenshot functionality
    slurp # screenshot functionality
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

      "gtk-4.0/settings.ini".source = ../../config/gtk-4.0/settings.ini;
    };

  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  dconf.settings = {

    # Extensions and basic conf
    "org/gnome/shell" = {
      favorite-apps = [
        "firefox.desktop"
        "brave-browser.desktop"
        #"emacs.desktop"
        "emacsclient.desktop"
        "kitty.desktop"
        "slack.desktop"
        "org.gnome.Nautilus.desktop"
      ];
      enabled-extensions = [
        "appindicatorsupport@rgcjonas.gmail.com"
        "pop-shell@system76.com"
        "workspace-indicator@gnome-shell-extensions.gcampax.github.com"
        "auto-move-windows@gnome-shell-extensions.gcampax.github.com"
      ];
    };
    "org/gnome/desktop/interface" = {
      clock-show-weekday = true;
      color-scheme = "prefer-dark";
      enable-hot-corners = false;
      scaling-factor = lib.hm.gvariant.mkUint32 2;
      text-scaling-factor = lib.hm.gvariant.mkDouble 0.7;
    };
    "org/gnome/mutter" = {
      attach-modal-dialogs = true;
      dynamic-workspaces = false;
      edge-tiling = false;
      focus-change-on-pointer-rest = true;
      workspaces-only-on-primary = true;
    };

    # Workspace Configs
    "org/gnome/desktop/wm/preferences" = {
      focus-new-windows = "smart";
      num-workspaces = 7;
      workspace-names = [
        "Personal"
        "Work"
        "Code"
        "Terminal"
        "Comms"
        "Music"
        "Misc"
      ];
    };

    # Shortcuts
    "org/gnome/mutter/keybindings" = {
      toggle-tiled-left = [];
      toggle-tiled-right = [];
    };
    "org/gnome/mutter/wayland/keybindings" = {
      restore-shortcuts = [];
    };
    "org/gnome/desktop/wm/keybindings" = {
      begin-move = [];
      maximize = [];
      unmaximize = [];
    };
    "org/gnome/shell/keybindings" = {
      toggle-application-view = [];
    };

    # Extensions
    ## Pop Shell
    "org/gnome/shell/extensions/pop-shell" = {
      active-hint = false;
      show-title = false;
      smart-gaps = false;
      tile-by-default = true;

    };

    "org/gnome/shell/extensions/auto-move-windows" = {
      application-list = [
        "firefox.desktop:1"
        "brave-browser.desktop:2"
        "emacsclient.desktop:3"
        "emacs.desktop:3"
        "kitty.desktop:4"
        "slack.desktop:5"
      ];
    };
  };
}
