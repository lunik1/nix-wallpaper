#!/usr/bin/env sh

set -eu

basename() {
    dir=${1%"${1##*[!/]}"}
    dir=${dir##*/}
    dir=${dir%"$2"}
    printf '%s\n' "${dir:-/}"
}

dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
out=$(realpath "${dir}"/../previews)

if [ -e "${out}" ]; then
  printf "Error: %s already exists\n" "${out}" >&2
  exit 1
fi

mkdir -p "${out}"

for f in "${dir}"/../data/presets/*.nix; do
  theme=$(basename "$f" ".nix")
  printf "Generating preview for %s\n" "$theme"

  nix build \
    --impure \
    --expr "(builtins.getFlake \"${dir}/..\").packages.\${builtins.currentSystem}.default.override { width = 150; height = 150; logoSize = 80; preset = \"${theme}\"; }"
  install -m644 result/share/wallpapers/nixos-wallpaper.png "${out}/${theme}.png"
done

rm -rf result
