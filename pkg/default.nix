{ lib
, runCommandLocal
, imagemagick

, preset ? "official"
, width ? 3480
, height ? 2160
, logoSize ? 44.25

, backgroundColor ? null
, logoColors ? { }
,
}:

let
  colorscheme = import ../data/presets/${preset}.nix
    // logoColors //
    lib.optionalAttrs (backgroundColor != null) { inherit backgroundColor; };
in
runCommandLocal "nix-wallpaper"
rec {
  inherit width height;
  inherit (colorscheme) color0 color1 color2 color3 color4 color5 backgroundColor;
  buildInputs = [ imagemagick ];
  density = 1200;
  # 72 is the default density
  # 323 is the height of the image rendered by default
  scale = 72.0 / density * height / 323.0 * 100;
} ''
  mkdir -p $out/share/wallpapers
  substituteAll ${../data/svg/wallpaper.svg} wallpaper.svg
  convert \
    -resize ''${scale}% \
    -density $density \
    -background $backgroundColor \
    -gravity center \
    -extent ''${width}x''${height} \
    wallpaper.svg $out/share/wallpapers/nixos-wallpaper.png
''
