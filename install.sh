#!/bin/bash
# Preview by default. Never adopt, overwrite, or automatically back up configs.
set -euo pipefail
cd "$(dirname "$0")"
repo="$(pwd -P)"
mode="${1:---dry-run}"
case "$mode" in
  --dry-run|--apply) ;;
  *) printf 'Usage: bash install.sh [--dry-run|--apply]\n' >&2; exit 2 ;;
esac
command -v stow >/dev/null 2>&1 || {
  printf 'Install Homebrew, then run: brew bundle --file="%s/Brewfile"\n' "$repo" >&2
  exit 1
}

# Ghostty can load this legacy location alongside ~/.config/ghostty/config.
legacy="$HOME/Library/Application Support/com.mitchellh.ghostty"
for file in "$legacy/config" "$legacy/config.ghostty"; do
  if [[ -e "$file" || -L "$file" ]]; then
    printf 'Existing Ghostty config: %s\nBack it up outside Ghostty config locations before installing.\n' "$file" >&2
    exit 1
  fi
done

# A full preflight detects conflicts before creating any links. No folder folding:
# runtime wallpaper files should live in ~/.config/ghostty, not inside this repo.
packages=(zsh nvim ghostty starship)
stow --dir="$repo" --target="$HOME" --no-folding --simulate --verbose "${packages[@]}"
if [[ "$mode" == --apply ]]; then
  mkdir -p "$HOME/Pictures/Wallpapers"
  stow --dir="$repo" --target="$HOME" --no-folding --verbose "${packages[@]}"
else
  printf '\nPreview only. To install: bash install.sh --apply\n'
fi
