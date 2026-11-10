#!/bin/bash
# Preview by default. Explicit backups move conflicts; never adopt or overwrite.
set -euo pipefail
cd "$(dirname "$0")"
repo="$(pwd -P)"
mode=--dry-run
backup=0
packages=()
usage() {
  printf 'Usage: bash install.sh [--dry-run|--apply] [--backup] [zsh nvim ghostty starship ...]\n'
}
for arg in "$@"; do
  case "$arg" in
    --dry-run|--apply) mode="$arg" ;;
    --backup) backup=1 ;;
    --help|-h) usage; exit 0 ;;
    zsh|nvim|ghostty|starship)
      found=0
      for package in "${packages[@]+"${packages[@]}"}"; do
        [[ "$package" == "$arg" ]] && found=1
      done
      (( found )) || packages+=("$arg")
      ;;
    *) printf 'Unknown option or package: %s\n' "$arg" >&2; usage >&2; exit 2 ;;
  esac
done
if [[ ${#packages[@]} -eq 0 ]]; then
  packages=(zsh nvim ghostty starship)
fi
command -v stow >/dev/null 2>&1 || {
  printf 'Install Homebrew, then run: brew bundle --file="%s/Brewfile"\n' "$repo" >&2
  exit 1
}

conflicts=()
add_conflict() {
  local target="$1" existing
  for existing in "${conflicts[@]+"${conflicts[@]}"}"; do
    # Moving an ancestor already covers this target (including symlink ancestors).
    [[ "$target" == "$existing" || "$target" == "$existing/"* ]] && return 0
  done
  # An application-level backup can replace previously planned file backups.
  local kept=()
  for existing in "${conflicts[@]+"${conflicts[@]}"}"; do
    [[ "$existing" == "$target/"* ]] || kept+=("$existing")
  done
  conflicts=("${kept[@]+"${kept[@]}"}")
  conflicts+=("$target")
}

# Plan conflicts without touching the target. Inspect ancestors as well as leaves,
# so an unrelated directory symlink is moved, never followed into another config.
for package in "${packages[@]}"; do
  while IFS= read -r -d '' source; do
    relative="${source#"$repo/$package/"}"
    target="$HOME/$relative"
    parent="$HOME"
    rest="$relative"
    blocked=0
    while [[ "$rest" == */* ]]; do
      part="${rest%%/*}"
      rest="${rest#*/}"
      parent="$parent/$part"
      if [[ -L "$parent" ]]; then
        if ! [[ "$parent" -ef "$repo/$package/${parent#"$HOME/"}" ]]; then
          add_conflict "$parent"
          blocked=1
          break
        fi
      elif [[ -e "$parent" && ! -d "$parent" ]]; then
        add_conflict "$parent"
        blocked=1
        break
      fi
    done
    if (( ! blocked )) && [[ -e "$target" || -L "$target" ]]; then
      # Only accept an existing symlink to this exact source as already managed.
      if ! { [[ -L "$target" ]] && [[ "$target" -ef "$source" ]]; }; then
        add_conflict "$target"
      fi
    fi
  done < <(find "$repo/$package" \( -type f -o -type l \) -print0)

  # Back up conflicting application configs as a unit: leaving old, untracked
  # Lua plugins behind could silently mix the old Neovim setup with this one.
  if [[ "$package" == nvim || "$package" == ghostty ]]; then
    app_root="$HOME/.config/$package"
    for target in "${conflicts[@]+"${conflicts[@]}"}"; do
      if [[ "$target" == "$app_root/"* ]]; then
        add_conflict "$app_root"
        break
      fi
    done
  fi

  if [[ "$package" == ghostty ]]; then
    # Ghostty can load these alongside ~/.config/ghostty/config.
    legacy="$HOME/Library/Application Support/com.mitchellh.ghostty"
    for target in "$legacy/config" "$legacy/config.ghostty"; do
      if [[ -e "$target" || -L "$target" ]]; then add_conflict "$target"; fi
    done
  fi
done

if [[ ${#conflicts[@]} -gt 0 ]]; then
  printf 'Conflicting targets:\n'
  printf '  %s\n' "${conflicts[@]}"
  if (( ! backup )); then
    printf 'No changes made. Preview backups with --backup, or apply with --apply --backup.\n' >&2
    exit 1
  fi
  backup_dir="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
  suffix=0
  base="$backup_dir"
  while [[ -e "$backup_dir" || -L "$backup_dir" ]]; do
    suffix=$((suffix + 1))
    backup_dir="$base-$suffix"
  done
  printf 'Backup destination: %s (relative paths preserved)\n' "$backup_dir"
  if [[ "$mode" == --dry-run ]]; then
    printf 'Preview only: would move these conflicts, then restow: %s\n' "${packages[*]}"
    printf 'Stow preflight will run after conflicts are moved on --apply.\n'
    exit 0
  fi
  mkdir "$backup_dir"
  for target in "${conflicts[@]}"; do
    destination="$backup_dir/${target#"$HOME/"}"
    mkdir -p "$(dirname "$destination")"
    mv -n "$target" "$destination"
    # BSD mv -n can report success when skipping; never proceed in that case.
    if [[ -e "$target" || -L "$target" ]]; then
      printf 'Backup failed for %s; stopping. Backups retained at %s\n' "$target" "$backup_dir" >&2
      exit 1
    fi
  done
  printf 'Backups saved in %s\n' "$backup_dir"
fi

# A full Stow preflight before changing links. Backups, if requested, have already
# moved; a later failure does not automatically restore them. See the README.
stow --dir="$repo" --target="$HOME" --no-folding --restow --simulate --verbose "${packages[@]}"
if [[ "$mode" == --apply ]]; then
  for package in "${packages[@]}"; do
    [[ "$package" != ghostty ]] || mkdir -p "$HOME/Pictures/Wallpapers"
  done
  stow --dir="$repo" --target="$HOME" --no-folding --restow --verbose "${packages[@]}"
else
  printf '\nPreview only. To install: bash install.sh --apply [--backup] [packages ...]\n'
fi
