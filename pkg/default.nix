{ runCommandLocal
, imagemagick

, bg_color ? "#ffffff"
, color0 ? "#7ebae4"
, color1 ? "#5277c3"
, color2 ? "#7ebae4"
, color3 ? "#5277c3"
, color4 ? "#7ebae4"
, color5 ? "#5277c3"
, width ? 3480
, height ? 2160
, logoSize ? 44.25
,
}:

runCommandLocal "nix-wallpaper"
rec {
  inherit color0 color1 color2 color3 color4 color5 bg_color width height;
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
    -background $bg_color \
    -gravity center \
    -extent ''${width}x''${height} \
    wallpaper.svg $out/share/wallpapers/nixos-wallpaper.png
''
