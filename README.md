# Dotfiles

Portable macOS configuration for LazyVim/Neovim, Ghostty, Zsh, and Starship.
GNU Stow links reviewed config files into your home directory. Fonts and tools
are installed through Homebrew; no wallpaper images or credentials are bundled.

## Install on a Mac

1. Install [Homebrew](https://brew.sh) and Git if needed.
2. Clone this repository to a permanent location, for example `~/dotfiles`.
3. Install dependencies:

   ```sh
   cd ~/dotfiles
   brew bundle
   ```

4. **Back up existing configs outside their application config directories.**
   Check `~/.zshrc`, `~/.config/nvim`, `~/.config/ghostty`,
   `~/.config/starship.toml`, and Ghostty's alternative location:
   `~/Library/Application Support/com.mitchellh.ghostty/` (`config` or
   `config.ghostty`). Review your existing shell settings before replacing them.
   This installer will refuse conflicts rather than overwrite or adopt files.
5. Preview, then explicitly install:

   ```sh
   bash install.sh             # dry run; no links created
   bash install.sh --apply
   ```

6. Open a new Ghostty window. Start `nvim` and allow LazyVim/Mason to install
   plugins and Roslyn. Authenticate Copilot separately if you use it.

Do not move the repo after installing: the symlinks point into it. To unlink:

```sh
stow --target="$HOME" --delete zsh nvim ghostty starship
```

The setup script does not install Homebrew, download wallpapers, load launch
agents, or change your active shell. Neovim language tools may require additional
runtimes (for example Node.js or an appropriate .NET SDK); install these for the
projects you work on. Docker Desktop is optional and is not installed here.

## Wallpapers

Wallpapers are not included. Place your own PNG/JPG/JPEG images directly in:

```sh
mkdir -p ~/Pictures/Wallpapers
```

The script runs when an interactive Ghostty shell starts, including new tabs.
It selects a random wallpaper on the first such startup each calendar day,
avoiding the previous selection when more than one image exists. It does not
rotate on a timer or on every tab. A missing/empty folder is harmless.

The selected background is written to `~/.config/ghostty/daily-wallpaper.ghostty`
and Ghostty is signalled to reload it. State, locks, and generated config stay
local and are ignored by Git. Images are used directly, not copied into the repo.
To force another selection, remove `~/.config/ghostty/daily-wallpaper.state`
and open a new Ghostty shell.

If migrating from the old scheduled setup on the original Mac, unload its
launch agent separately before using this version:

```sh
launchctl bootout "gui/$(id -u)" "$HOME/Library/LaunchAgents/com.connor.ghostty.daily-wallpaper.plist"
```

Then move that plist out of `~/Library/LaunchAgents` so it does not return at
login. This repository neither installs nor automatically removes that old job.

## Terminal completion

Tab uses built-in Zsh completion with case-insensitive prefix matching, falling
back to substring matching. For example, in a folder containing `Bitforged/`:

```text
cd forg<Tab>  →  cd Bitforged/
```

When there are several matches, Tab cycles through a selectable menu. This is
substring matching, not arbitrary fuzzy subsequence matching. It searches the
command's normal completion candidates, not every directory on your Mac.
Docker Desktop completions are loaded only if their directory exists.

## Neovim

- Preserves the current LazyVim extras list and plugin lockfile, including SQL,
  TypeScript, Vue, YAML, and Dot alongside the existing extras.
- Keeps appearance, split shortcuts, Diffview, inline images, and Markdown defaults.
- Uses Roslyn for C# language features and formatting, rather than CSharpier.
- C# defaults to four spaces; Neovim's native EditorConfig support applies
  project and nested `.editorconfig` overrides afterward. Do not disable it if
  you want this behavior. Roslyn also reads applicable EditorConfig settings.
- Keeps C# on-type formatting and diagnostic refresh after pauses and on return
  to a buffer. The return-to-buffer refresh uses an optional private Neovim API;
  it is guarded if unavailable. The source configuration used Neovim 0.12.5.
- Excludes Unity diagnostic suppression, Unity CLI setup, and `.meta` filters.
- Omits the Obsidian-specific ancestor `zImages` resolver pending review.

The font is JetBrains Mono, installed via Homebrew rather than vendored.
The prompt includes special glyphs; if any render as boxes, install a Nerd Font
variant and adjust Ghostty's `font-family` locally as appropriate.

## Local settings and publishing

Optional `~/.zshrc.local` is loaded before the shared shell configuration. Keep
machine-specific environment variables there, for example:

```sh
export WALLPAPER_DIR="$HOME/Pictures/My Wallpapers"
```

Keep credentials in a credential manager, not this repository. Git ignores are
only a safety net: review `git diff --cached` before publishing. Configuration
changes made through the symlinks modify this repository. Neovim may update its
tracked lockfile as plugins change. The included Neovim starter license is kept
at `nvim/.config/nvim/LICENSE`; third-party plugins/fonts retain their own licenses.

## Quick manual checks after installation

- Open Ghostty: verify font, prompt, and background. With no wallpapers, it should
  still open normally. New tabs should retain the same day's selection.
- In `~/Projects`, try `cd forg<Tab>` with a `Bitforged` folder present.
- Open C# in Neovim: confirm Roslyn attaches, formatting works, and a project's
  `.editorconfig` indentation overrides the four-space fallback.
- Open Markdown and a Git diff to check image support and Diffview shortcuts.
