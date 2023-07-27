{inputs, ...}: final: prev: {
  waybar = inputs.hyprland.packages.${prev.stdenv.hostPlatform.system}.waybar-hyprland;
}
