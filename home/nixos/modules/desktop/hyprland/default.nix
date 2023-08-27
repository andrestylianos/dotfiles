{
  options,
  config,
  lib,
  pkgs,
  inputs,
  osConfig,
  ...
}: let
  apply-hm-env = pkgs.writeShellScript "apply-hm-env" ''
    ${lib.optionalString (config.home.sessionPath != []) ''
      export PATH=${builtins.concatStringsSep ":" config.home.sessionPath}:$PATH
    ''}
    ${builtins.concatStringsSep "\n" (lib.mapAttrsToList (k: v: ''
        export ${k}=${toString v}
      '')
      config.home.sessionVariables)}
    ${config.home.sessionVariablesExtra}
    exec "$@"
  '';

  # runs processes as systemd transient services
  run-as-service = pkgs.writeShellScriptBin "run-as-service" ''
    exec ${pkgs.systemd}/bin/systemd-run \
      --slice=app-manual.slice \
      --property=ExitType=cgroup \
      --user \
      --wait \
      bash -lc "exec ${apply-hm-env} $@"
  '';
  inherit (lib) mkEnableOption mkIf;
  cfg = config.hostConfig.desktop.hyprland;
in {
  options.hostConfig.desktop.hyprland = {
    enable = mkEnableOption "Hyprland desktop";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = osConfig.hostConfig.desktop.hyprland.enable;
        message = "Activating hyprland requires hostConfig.desktop.hyprland.enable set to true in configuration.nix";
      }
    ];

    home.packages = with pkgs; [
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
      inputs.hyprland-contrib.packages.${pkgs.hostPlatform.system}.grimblast
      playerctl
      #
      ## eww-hyprland
      material-design-icons
      jost

      run-as-service
    ];

    wayland.windowManager.hyprland.enable = true;
    programs = {
      zsh.shellAliases = {
        yay = "echo success";
      };
    };

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

    wayland.windowManager.hyprland.extraConfig = let
      homeDir = config.home.homeDirectory;
      launcher = "fuzzel";
    in ''
         $mod = SUPER

         monitor = HDMI-A-1,3840x2160@60,0x0,2
      #exec-once=systemctl --user import-environment DISPLAY WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP

         # scale apps
         exec-once = xprop -root -f _XWAYLAND_GLOBAL_OUTPUT_SCALE 32c -set _XWAYLAND_GLOBAL_OUTPUT_SCALE 2

         exec-once = ${pkgs.kwallet-pam}/libexec/pam_kwallet_init

         exec-once = wl-paste --watch cliphist store

         exec-once = systemctl --user start waybar

         exec-once = ${pkgs.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1 &

         misc {
           # enable Variable Frame Rate
           vfr = true
           # disable auto polling for config file changes
           disable_autoreload = false
           focus_on_activate = true
         }

         input {
           kb_layout = us
           kb_variant = intl
           numlock_by_default = true

           # focus change on cursor move
           follow_mouse = 1
           accel_profile = flat
         }

         general {
           gaps_in = 5
           gaps_out = 5
           border_size = 2

         }

         decoration {
           rounding = 16
           blur = true
           blur_size = 3
           blur_passes = 3
           blur_new_optimizations = true

           drop_shadow = true
           shadow_ignore_window = true
           shadow_offset = 2 2
           shadow_range = 4
           shadow_render_power = 1
           col.shadow = 0x55000000
         }

         animations {
           enabled = true
           animation = border, 1, 2, default
           animation = fade, 1, 4, default
           animation = windows, 1, 3, default, popin 80%
           animation = workspaces, 1, 2, default, slide
         }

         dwindle {
           # keep floating dimentions while tiling
           pseudotile = true
           preserve_split = true
         }

         # make Firefox PiP window floating and sticky
         windowrulev2 = float, title:^(Picture-in-Picture)$
         windowrulev2 = pin, title:^(Picture-in-Picture)$

         # throw sharing indicators away
         windowrulev2 = nofullscreenrequest, title:^(Firefox — Sharing Indicator)$
         windowrulev2 = workspace special silent, title:^(Firefox — Sharing Indicator)$
         windowrulev2 = float, title:^(Firefox — Sharing Indicator)$
         windowrulev2 = workspace special silent, title:^(.*is sharing (your screen|a window)\.)$

         windowrulev2 = float, class:^(kwalletd5)$
         windowrulev2 = pin, class:^(kwalletd5)$
         windowrulev2 = center, class:^(kwalletd5)$
         windowrulev2 = dimaround, class:^(kwalletd5)$

         windowrulev2 = workspace 1, class:^(.*Firefox)$
         windowrulev2 = idleinhibit fullscreen, class:^(firefox)$
         windowrulev2 = workspace 2, title:^(.*Brave)$
         windowrulev2 = workspace 3, title:^(.*Visual Studio Code)$
         windowrulev2 = workspace 5, title:^(.*Slack)$

         # start spotify tiled in ws9
         windowrulev2 = tile, class:^(Spotify)$
         windowrulev2 = workspace 9 silent, class:^(Spotify)$

         # idle inhibit while watching videos
         windowrulev2 = idleinhibit focus, class:^(mpv|.+exe)$

         # mouse movements
         bindm = $mod, mouse:272, movewindow
         bindm = $mod, mouse:273, resizewindow
         bindm = $mod ALT, mouse:272, resizewindow

         # compositor commands
         bind = $mod SHIFT, E, exec, pkill Hyprland
         bind = $mod, Q, killactive,
         bind = $mod, F, fullscreen,
         bind = $mod, G, togglegroup,
         bind = $mod SHIFT, N, changegroupactive, f
         bind = $mod SHIFT, P, changegroupactive, b
         bind = $mod, R, togglesplit,
         bind = $mod, T, togglefloating,
         bind = $mod, P, pseudo,
         bind = $mod ALT, ,resizeactive,
         # toggle "monocle" (no_gaps_when_only)
         $kw = dwindle:no_gaps_when_only
         bind = $mod, M, exec, hyprctl keyword $kw $(($(hyprctl getoption $kw -j | jaq -r '.int') ^ 1))

         # utility
         # launcher
         # bindr = $mod, SUPER_L, exec, pkill .${launcher}-wrapped || run-as-service ${launcher} --show run
         # bindr = $mod, D, exec, pkill .${launcher}-wrapped || run-as-service ${launcher} --show run
         bindr = $mod, D, exec, ${launcher} --show run
         bindr = $mod, V, exec, cliphist list | fuzzel -d | cliphist decode | wl-copy
         # terminal
         bind = $mod, Return, exec, run-as-service kitty
         # logout menu
         bind = $mod, Escape, exec, wlogout -p layer-shell
         # lock screen
         bind = $mod, L, exec, loginctl lock-session
         # select area to perform OCR on
         bind = $mod, O, exec, run-as-service wl-ocr

         # move focus
         bind = $mod, left, movefocus, l
         bind = $mod, right, movefocus, r
         bind = $mod, up, movefocus, u
         bind = $mod, down, movefocus, d

         # window resize
         bind = $mod, S, submap, resize

         submap = resize
         binde = , right, resizeactive, 10 0
         binde = , left, resizeactive, -10 0
         binde = , up, resizeactive, 0 -10
         binde = , down, resizeactive, 0 10
         bind = , escape, submap, reset
         submap = reset

         # media controls
         bindl = , XF86AudioPlay, exec, playerctl play-pause
         bindl = , XF86AudioPrev, exec, playerctl previous
         bindl = , XF86AudioNext, exec, playerctl next

         # volume
         bindle = , XF86AudioRaiseVolume, exec, wpctl set-volume -l "1.0" @DEFAULT_AUDIO_SINK@ 6%+
         bindle = , XF86AudioLowerVolume, exec, wpctl set-volume -l "1.0" @DEFAULT_AUDIO_SINK@ 6%-
         bindl = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
         bindl = , XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

         # backlight
         bindle = , XF86MonBrightnessUp, exec, light -A 5
         bindle = , XF86MonBrightnessDown, exec, light -U 5

         # screenshot
         # stop animations while screenshotting; makes black border go away
         $screenshotarea = hyprctl keyword animation "fadeOut,0,0,default"; grimblast --notify copysave area; hyprctl keyword animation "fadeOut,1,4,default"
         bind = , Print, exec, $screenshotarea
         bind = $mod SHIFT, R, exec, $screenshotarea

         bind = CTRL, Print, exec, grimblast --notify --cursor copysave output
         bind = $mod SHIFT CTRL, R, exec, grimblast --notify --cursor copysave output

         bind = ALT, Print, exec, grimblast --notify --cursor copysave screen
         bind = $mod SHIFT ALT, R, exec, grimblast --notify --cursor copysave screen

         # workspaces
         # binds mod + [shift +] {1..10} to [move to] ws {1..10}
         ${builtins.concatStringsSep "\n" (builtins.genList (
          x: let
            ws = let
              c = (x + 1) / 10;
            in
              builtins.toString (x + 1 - (c * 10));
          in ''
            bind = $mod, ${ws}, workspace, ${toString (x + 1)}
            bind = $mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}
          ''
        )
        10)}

         # special workspace
         bind = $mod SHIFT, grave, movetoworkspace, special
         bind = $mod, grave, togglespecialworkspace, eDP-1

         # cycle workspaces
         bind = $mod, bracketleft, workspace, m-1
         bind = $mod, bracketright, workspace, m+1
         # cycle monitors
         bind = $mod SHIFT, braceleft, focusmonitor, l
         bind = $mod SHIFT, braceright, focusmonitor, r
    '';
  };
}
