#!/usr/bin/env sh

set -eu pipefail

dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
out=$(realpath "${dir}"/../previews)

if [ -e "${out}" ]; then
  printf "Error: %s already exists\n" "${out}" >&2
  exit 1
fi

mkdir -p "${out}"

printf "Generating all previews...\n"

nix build \
  --impure \
  --expr "
let
  flake = builtins.getFlake \"${dir}/..\";
  system = builtins.currentSystem;
  pkgs = flake.inputs.nixpkgs.legacyPackages.\${system};
  lib = pkgs.lib;

  presetsDir = \"${dir}/../data/presets\";
  presets = lib.filterAttrs (n: v: v == \"regular\" && lib.hasSuffix \".nix\" n) (builtins.readDir presetsDir);
  presetNames = lib.mapAttrsToList (n: v: lib.removeSuffix \".nix\" n) presets;

  mkPreview = theme:
    let
      pkg = flake.packages.\${system}.default.override {
        width = 150;
        height = 150;
        logoSize = 80;
        preset = theme;
      };
    in
      {
        name = \"\${theme}.png\";
        path = \"\${pkg}/share/wallpapers/nixos-wallpaper.png\";
      };

  entries = map mkPreview presetNames;
in
  pkgs.linkFarm \"previews\" entries
"

install -m644 result/*.png "${out}/"
rm result
