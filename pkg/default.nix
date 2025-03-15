{
  lib,
  runCommandLocal,
  imagemagick,

  preset ? "official",
  width ? 3840,
  height ? 2160,
  logoSize ? 44.25,

  backgroundColor ? null,
  logoColors ? { },

  # secret option for source-code readers
  widdershins ? false,
}:

let
  isNixFile = file: type: (lib.hasSuffix ".nix" file && type == "regular");
  isColor =
    str:
    builtins.isString str
    && (builtins.isList (builtins.match "^#[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$" str));
  # Adds full opacity if none is provided
  opacityHex = str: builtins.substring 7 2 (str + "ff");
  opacityDec = str: lib.fromHexString (opacityHex str) / 255.0;
  opacity = name: value: if name == "backgroundColor" then opacityHex value else opacityDec value;
  opacityName =
    name:
    if name == "backgroundColor" then
      "backgroundOpacity"
    else
      "opacity" + (builtins.substring 5 1 name);
  color = str: builtins.substring 0 7 str;
in

assert builtins.isInt width && width > 0;
assert builtins.isInt height && height > 0;
assert (builtins.isInt logoSize || builtins.isFloat logoSize) && logoSize >= 0;
assert builtins.isString preset;
assert lib.assertMsg (lib.hasAttr "${preset}.nix" (
  lib.filterAttrs isNixFile (builtins.readDir ../data/presets)
)) "unknown preset \"${preset}\"";
assert lib.assertMsg (
  backgroundColor == null || isColor backgroundColor
) "backgroundColor should be a 6 or 8-digit hex code";
assert lib.assertMsg (builtins.all isColor (
  lib.attrValues logoColors
)) "logoColors should contain 6 or 8-digit hex codes";
assert lib.assertMsg (builtins.all (str: builtins.isList (builtins.match "^color[0-5]$" str)) (
  lib.attrNames logoColors
)) "logoColors should contain keys named color[0-5]";
assert builtins.isBool widdershins;

let
  finalColors =
    import ../data/presets/${preset}.nix
    // logoColors
    // lib.optionalAttrs (backgroundColor != null) { inherit backgroundColor; };
  colorscheme = lib.concatMapAttrs (name: value: {
    ${name} = color value;
    ${opacityName name} = opacity name value;
  }) finalColors;
in
runCommandLocal "nix-wallpaper"
  rec {
    inherit width height;
    inherit (colorscheme)
      color0
      color1
      color2
      color3
      color4
      color5
      backgroundColor
      opacity0
      opacity1
      opacity2
      opacity3
      opacity4
      opacity5
      backgroundOpacity
      ;
    buildInputs = [ imagemagick ];
    density = 1200;
    # 72 is the default density
    # 323 is the height of the image rendered by default
    scale = 72.0 / density * height / 323.0 * logoSize;
    flop = if widdershins then "-flop" else "";
  }
  ''
    mkdir -p $out/share/wallpapers
    substituteAll ${../data/svg/wallpaper.svg} wallpaper.svg
    ${lib.getExe imagemagick} \
      -density $density \
      -background ''${backgroundColor}''${backgroundOpacity} \
      wallpaper.svg \
      -resize ''${scale}% \
      -gravity center \
      -extent ''${width}x''${height} \
      $flop \
      $out/share/wallpapers/nixos-wallpaper.png
  ''
