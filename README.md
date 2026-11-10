# Dotfiles

Portable macOS configuration for LazyVim/Neovim, Ghostty, Zsh, and Starship.
GNU Stow links reviewed config files into your home directory. Fonts and tools
are installed through Homebrew; no wallpaper images or credentials are bundled.

See the [terminal style guide](STYLE-GUIDE.md) for the preferred color palette,
semantic roles, typography, and conditional banner separators. It is a
tool-independent reference, without copying Pi configuration.

## Install on a Mac

1. Install [Homebrew](https://brew.sh) and Git if needed.
2. Clone to a permanent location, for example `~/dotfiles`:

   ```sh
   git clone https://github.com/connorwally/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

3. If this machine normally uses a different Git identity (for example a work
   account), set the intended **commit identity for this clone only**:

   ```sh
   git config --local user.name "Your Name"
   git config --local user.email "your-personal-email@example.com"
   git var GIT_AUTHOR_IDENT
   ```

   This does not change global identity or the account used to authenticate pushes.
   Do not copy credentials into this repository.

4. Install dependencies:

   ```sh
   brew bundle
   ```

   **Existing machine?** Read [Homebrew on existing machines](#homebrew-on-existing-machines)
   first. Package selection below limits config linking, not this Brewfile.

5. Preview, then explicitly install:

   ```sh
   bash install.sh                         # preview; no changes
   bash install.sh --backup                # preview backups for conflicts
   bash install.sh --apply --backup        # back up conflicts, then link configs
   ```

   Without `--backup`, conflicts stop installation. No configuration is adopted,
   overwritten, or deleted to resolve a conflict. Review existing shell settings:
   a backup preserves them but does not merge them into the new configuration.

6. Open a new Ghostty window. Start `nvim` and allow LazyVim/Mason to install
   plugins and language tools. **Roslyn installs on Neovim's first start, not
   during `brew bundle` or Stow installation.** Wait for Mason to finish; C#
   language features may not be ready immediately. Authenticate Copilot separately.

7. Optionally bootstrap plugins headlessly, then check the lockfile as described
   in [Neovim first run](#neovim-first-run-and-lockfile).

The installer does not install Homebrew, download wallpapers, load launch agents,
change your login shell, or launch Neovim. This repository omits Unity-specific
configuration. Keep the original machine's Unity setup unless deliberately
migrating it; testing with a separate `NVIM_APPNAME` profile is another option.

## Backups and conflicts

`--backup` moves conflicting targets to a unique directory such as:

```text
~/dotfiles-backup-20261110-153000/
├── .zshrc
├── .config/
│   ├── nvim/
│   ├── ghostty/
│   └── starship.toml
└── Library/Application Support/com.mitchellh.ghostty/config.ghostty
```

Only conflicts for the selected packages are considered. Already-correct repo
symlinks are left alone. A conflicting ancestor symlink is backed up as a symlink,
not followed into another location. For Neovim and Ghostty, conflicts inside their
config directories cause the **whole application config directory** to be moved,
so old Lua plugins/config fragments do not accidentally mix with the new setup.
Ghostty's legacy `config` and `config.ghostty` files in Application Support are
also checked when installing the Ghostty package.

Backups retain relative paths and are never automatically deleted. The installer
previews the planned moves, and uses Stow's simulation before changing links.
When backups are necessary, that Stow check runs **after** the conflicts have been
moved. If a later step fails, backups remain available; restoration is not automatic.

To restore, first unlink the relevant package with Stow, inspect any new local
files, then move the saved paths back to their original locations. Do not blindly
copy backups over active symlinks: that could modify files in this repository.

## Partial installs

Available configuration packages: `zsh`, `nvim`, `ghostty`, `starship`.
Omitting package names selects all four.

```sh
bash install.sh zsh starship                    # preview only these packages
bash install.sh --apply --backup nvim           # only Neovim
bash install.sh --apply ghostty starship        # only terminal appearance/prompt
```

Unknown package names are rejected before changes are made. Conflicts in unselected
packages do not block installation. Shell integrations for missing apps are guarded;
shortcuts such as `n` still require their corresponding application to be installed.
For the intended combined look, install both `ghostty` and `starship`.

`brew bundle` still installs the **full** dependency list. For a deliberately
minimal install, install `stow` and only the dependencies needed by your chosen
packages instead; there is no automatic package-to-Brewfile filtering.

## Update and restow after pulling

```sh
cd ~/dotfiles
git pull --ff-only
bash install.sh                       # inspect conflicts/changes
bash install.sh --apply               # restow all packages
```

For a partial installation, **repeat the same package selection** on updates:

```sh
bash install.sh --apply zsh starship
```

The installer uses `stow --restow --no-folding`. Restowing reconciles links after
files are added, removed, or moved. It does not back up conflicts unless you also
pass `--backup`. Run `brew bundle` when you want to apply changed dependencies;
review updates first. Open a new shell/reload the application afterward.

Do not move the repo after installing: symlinks point into it. To unlink packages:

```sh
cd ~/dotfiles
stow --target="$HOME" --delete zsh nvim ghostty starship
```

### Why `--no-folding`? The escape hatch for new files

Stow normally can link a whole directory to the repo, for example making
`~/.config/ghostty` itself a symlink. With `--no-folding`, the directories remain
real directories and individual config files are linked instead. Generated
wallpaper state/logs can then stay on the machine rather than appearing in Git.

The trade-off: editing an **existing linked file** takes effect immediately, but
adding a **new file to the repo** does not automatically create its target link.
If a newly pulled plugin or config file appears to be ignored, the escape hatch
is to **restow its package**:

```sh
bash install.sh --apply nvim
```

Do not work around this by copying the new file into place, using `stow --adopt`,
or removing `--no-folding`; those can create conflicts or bring local files into
the repository. Restowing keeps the file-level linking policy intact.

## Homebrew on existing machines

- `brew bundle` installs/updates listed dependencies; it does not migrate or
  overwrite your shell/editor configuration. The separate installer handles links.
- Existing manually installed apps such as Ghostty can conflict with cask installs.
  Review Homebrew's message and preserve the existing app/config rather than using
  force options blindly. You can install missing dependencies individually.
- This repo installs **JetBrains Mono Nerd Font** using
  `font-jetbrains-mono-nerd-font`; it does not vendor font binaries. Ghostty requests
  the family `JetBrainsMono Nerd Font`, Medium/Medium Italic at size 16.
- The Nerd Font can coexist with ordinary JetBrains Mono. You do not need to
  uninstall the ordinary font. Reload Ghostty after installing the new font.
- Do **not** run `brew bundle cleanup --force` as part of setup: it can remove
  unrelated software already installed on the machine.
- Docker Desktop, .NET SDKs, and project language runtimes are not installed here.
  Install the ones needed for your projects (for example Node.js for relevant
  language tools). Mason-installed servers may have their own runtime requirements.

## Neovim first run and lockfile

The repository tracks `nvim/.config/nvim/lazy-lock.json`. After linking the Neovim
package, an optional plugin bootstrap is:

```sh
nvim --headless "+Lazy! sync" +qa
```

This loads your active Neovim configuration, downloads plugins, and may update the
lockfile. **Only run it after confirming that `~/.config/nvim` points to the desired
profile.** It is not run automatically by the installer. It is a plugin-sync step,
not a guarantee that every parser/language server has finished installing.

Immediately afterward (and after the first interactive start), check:

```sh
cd ~/dotfiles
git status --short -- nvim/.config/nvim/lazy-lock.json
git diff -- nvim/.config/nvim/lazy-lock.json
```

**Expected: no output, meaning the lockfile is clean.** A first-run rewrite to
older commits has been observed. Do not blindly commit it as an intentional update:
inspect the diff and resolve the plugin-version mismatch before treating bootstrap
as complete. Also review any other first-run modifications with `git status --short`.
If reproducibility is the goal and there are no intentional lockfile changes to
keep, restore the committed file with
`git restore --source=HEAD -- nvim/.config/nvim/lazy-lock.json`, then use
`:Lazy restore` in Neovim to reinstall those recorded versions. Review first:
`git restore` discards local changes to that file. Recheck the diff afterward.

**Roslyn installs via Mason on the first Neovim start**, not during the shell
installer. Open Neovim interactively, check `:Mason`, and allow the install to finish
before checking C# with `:checkhealth` or attached LSP clients. Headless process exit
alone does not prove Roslyn finished installing. Do not include Copilot credentials
or machine-specific server state in Git.

### Included behavior

- Current LazyVim extras and plugin lockfile, including SQL, TypeScript, Vue, YAML,
  and Dot alongside the existing extras.
- Appearance, split shortcuts, Diffview, inline images, and Markdown defaults.
- Roslyn for C# language features and formatting, rather than CSharpier.
- C# four-space fallback; native EditorConfig applies project/nested overrides.
  Roslyn also reads applicable EditorConfig settings.
- C# on-type formatting and diagnostic refresh after pauses and on return to a
  buffer. Return-to-buffer refresh uses a guarded private API; the source setup
  used Neovim 0.12.5.
- No Unity diagnostic suppression, Unity CLI setup, or `.meta` filters.
- No Obsidian-specific ancestor `zImages` resolver pending review.

## Wallpapers

Wallpapers are not included. Place PNG/JPG/JPEG images directly in:

```sh
mkdir -p ~/Pictures/Wallpapers
```

The script runs when an interactive Ghostty shell starts, including new tabs.
It selects a random wallpaper on the first such startup each calendar day,
avoiding the previous selection when possible. There is no timer. A missing/empty
folder is harmless.

Output: `~/.config/ghostty/daily-wallpaper.ghostty`. State, locks, and generated
config remain local and ignored by Git. Images are used directly, not copied into
the repo. To force another selection, remove `~/.config/ghostty/daily-wallpaper.state`
and open a new Ghostty shell.

When migrating from the old scheduled setup, unload it separately if still present:

```sh
launchctl bootout "gui/$(id -u)" "$HOME/Library/LaunchAgents/com.connor.ghostty.daily-wallpaper.plist"
```

Move the old plist out of `~/Library/LaunchAgents` so it cannot return at login.
The installer does not remove scheduled tasks. This migration has already been
performed on the original machine.

## Terminal completion

Tab uses case-insensitive prefix matching, then substring matching:

```text
cd forg<Tab>  →  cd Bitforged/
```

Multiple matches open a selectable menu. This searches normal completion candidates,
not every directory on your Mac. Docker Desktop completions load only if present.

## Local shell hooks and publishing

Two optional, untracked hooks have different purposes:

- **`~/.zshrc.local`**: early environment settings, before Homebrew, completion,
  wallpaper selection, and prompt initialization. For example:

  ```sh
  export WALLPAPER_DIR="$HOME/Pictures/My Wallpapers"
  ```

- **`~/.zshrc.local.after`**: loaded last, so local aliases, keybindings, completion
  styles, and prompt overrides take priority over shared defaults. Use the early
  hook for settings that must exist before initialization; the late hook does not
  rerun earlier startup steps.

Keep credentials in a credential manager. Review `git diff --cached` before
publishing; ignores are only a safety net. Changes through symlinks modify this
repository. The Neovim starter license is retained at `nvim/.config/nvim/LICENSE`;
third-party plugins/fonts retain their own licenses.

## Quick manual checks after installation

- Ghostty: verify font/glyphs, prompt, fullscreen behavior, and background. With no
  wallpapers, startup should still work; new tabs retain the same day's selection.
- In `~/Projects`, try `cd forg<Tab>` with a `Bitforged` directory present.
- Check prompt separators inside and outside Git: only the final triangle should
  have a transparent background.
- Neovim: confirm the lockfile remains clean after bootstrap/first run; wait for
  Roslyn in Mason, then verify C# formatting and project EditorConfig precedence.
- Check Markdown images and Diffview shortcuts. Verify a late shell override wins.
