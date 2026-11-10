# Early machine-specific environment (not tracked). Export WALLPAPER_DIR here.
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# Portable Homebrew setup for Apple Silicon and Intel Macs.
if ! command -v brew >/dev/null 2>&1; then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

# Optional Docker Desktop completions, registered before compinit.
[[ -d "$HOME/.docker/completions" ]] && fpath=("$HOME/.docker/completions" $fpath)
autoload -Uz compinit
compinit
zmodload zsh/complist

# Case-insensitive substring completion: `cd forg<Tab>` can match Bitforged
# in the current directory. Prefer prefix matches, then try substring matches.
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'm:{a-zA-Z}={A-Za-z} l:|=* r:|=*'
zstyle ':completion:*' menu select
bindkey '^I' menu-complete

# Daily wallpaper selection runs only when an interactive Ghostty shell starts.
if [[ "$TERM_PROGRAM" == ghostty && -f "$HOME/.config/ghostty/daily-wallpaper.zsh" ]]; then
  /bin/zsh "$HOME/.config/ghostty/daily-wallpaper.zsh"
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

alias n='nvim'
alias lg='lazygit'
alias ld='lazydocker'

# Late local overrides win over shared aliases, prompt, completion, and keymaps.
[[ -f "$HOME/.zshrc.local.after" ]] && source "$HOME/.zshrc.local.after"
