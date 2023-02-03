{ lib
, runCommandLocal
, imagemagick

, preset ? "official"
, width ? 3480
, height ? 2160
, logoSize ? 44.25

, backgroundColor ? null
, color0 ? null
, color1 ? null
, color2 ? null
, color3 ? null
, color4 ? null
, color5 ? null
,
}:

let
  colorscheme = import ../data/presets/${preset}.nix //
    lib.filterAttrs (_: v: v != null) { inherit backgroundColor color0 color1 color2 color3 color4 color5; };
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
