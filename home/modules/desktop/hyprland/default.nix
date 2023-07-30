{
  options,
  config,
  lib,
  pkgs,
  inputs,
  osConfig,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.hostConfig.desktop.hyprland;
in {
  imports = [
    ./config.nix
  ];
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
  };
}
