{hyprland, ...}: final: prev: {
  waybar = hyprland.packages.${prev.stdenv.hostPlatform.system}.waybar-hyprland;
}
