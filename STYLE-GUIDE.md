# Terminal style guide

A tool-independent reference for recreating the preferred look across editors,
terminals, and coding assistants. Inspired by **Tokyo Night Moon**, with pink and
magenta accents and a custom brighter blue. This documents the locally tuned
appearance; it is not an unmodified copy of the upstream theme.

This is a design specification, not executable configuration. No Pi settings,
sessions, credentials, or theme file are needed to use it. Apply the supported
parts in each tool; a tool such as Claude Code may not expose every color role.
Do not assume Markdown or this document can force colors in an application.

## Visual direction

- Dark, cool-toned surfaces with soft, pale body text.
- **Pink is the primary accent; magenta provides structure.** Blue is secondary.
- Keep the brighter blue **RGB(115, 185, 248), `#73B9F8`**. Do not swap its role
  with pink/magenta; that experiment was reverted.
- Avoid green as a general decorative accent. Reserve it mainly for diff additions.
- Keep the main terminal background transparent/default so Ghostty's dim wallpaper
  remains visible. Use opaque surfaces selectively for panels and selections.
- Prefer restrained accents over coloring entire paragraphs or filling every panel.

## Palette

Hex values are sRGB. The token names below are portable design names rather than
application-specific configuration keys.

| Token | Hex | RGB | Intended use |
| --- | --- | --- | --- |
| `background` | `#222436` | 34, 36, 54 | Solid fallback/page background when transparency is unavailable |
| `surface` | `#1E2030` | 30, 32, 48 | Tool panels, custom messages, cards |
| `surface-highlight` | `#2F334D` | 47, 51, 77 | User-message panels and selected rows |
| `text` | `#C8D3F5` | 200, 211, 245 | Body text, normal code, tool output |
| `text-muted` | `#828BB8` | 130, 139, 184 | Secondary labels, thinking text, quotes, diff context |
| `border-muted` | `#3B4261` | 59, 66, 97 | Quiet borders, dividers, scrollbar tracks |
| `comment` | `#636DA6` | 99, 109, 166 | Code comments and dim, nonessential text |
| `inactive` | `#545C7E` | 84, 92, 126 | Inactive indicators; not normal body text |
| `blue` | `#73B9F8` | 115, 185, 248 | Functions and secondary emphasis; custom brighter blue |
| `cyan` | `#86E1FC` | 134, 225, 252 | Links, operators, punctuation |
| `teal` | `#4FD6BE` | 79, 214, 190 | Link destinations and supporting link detail |
| `green` | `#C3E88D` | 195, 232, 141 | Reference palette green; not a default decorative accent |
| `magenta` | `#C099FF` | 192, 153, 255 | Borders, headings, tool titles, keywords, labels |
| `pink` | `#FCA7EA` | 252, 167, 234 | Primary accent, inline code, strings, success indicators |
| `orange` | `#FF966C` | 255, 150, 108 | List markers and numeric literals |
| `red` | `#FF757F` | 255, 117, 127 | Errors and highest-urgency indicators |
| `yellow` | `#FFC777` | 255, 199, 119 | Warnings, types, search-match text, shell-mode indicator |
| `diff-added` | `#B8DB87` | 184, 219, 135 | Added lines; retain green for familiar diff semantics |
| `diff-removed` | `#E26A75` | 226, 106, 117 | Removed lines |
| `search-background` | `#3D3548` | 61, 53, 72 | Search-match background, paired with yellow text |
| `error-surface` | `#3A273A` | 58, 39, 58 | Failed-tool/error panel background |

## Semantic usage

### Interface and panels

| Element | Foreground | Background / treatment |
| --- | --- | --- |
| Main body | `text` | Terminal default; solid fallback `background` |
| Primary accent | `pink` | No required fill |
| Active/accent borders | `magenta` | Terminal default or owning panel |
| Quiet borders and horizontal rules | `border-muted` | Owning surface |
| User messages | `text` | `surface-highlight` |
| Custom/info messages | `text`, labels in `magenta` | `surface` |
| Pending and successful tool output | `text`, title in `magenta` | `surface`; do not flood success panels green |
| Failed tool output | `text`, error indicator in `red` | `error-surface` |
| Success indicator | `pink` | Also use a checkmark or label; color alone is insufficient |
| Warning indicator | `yellow` | Pair with an icon or label |
| Error indicator | `red` | Pair with an icon or label |
| Selected row | `text` | `surface-highlight` |
| Search match | `yellow` | `search-background` |
| Scrollbar | Thumb `text-muted` | Track `border-muted` |

### Markdown and syntax

| Element | Color / treatment |
| --- | --- |
| Headings | `magenta`, bold where supported |
| Inline code | `pink` |
| Code-block fallback text | `text`; use syntax roles below when available |
| Code-block borders | `border-muted` |
| Links | `cyan`; underline where useful |
| Link destinations | `teal` |
| Quotes | `text-muted`, with a `magenta` quote border |
| List markers | `orange` where separately styleable; body stays `text` |
| Comments | `comment` |
| Keywords | `magenta` |
| Functions | `blue` |
| Variables | `text` |
| Strings | `pink` |
| Numbers | `orange` |
| Types | `yellow` |
| Operators and punctuation | `cyan` |
| Diff additions / removals / context | `diff-added` / `diff-removed` / `text-muted` |

Some renderers cannot color list numbers separately or distinguish link labels
from destinations. Preserve readability rather than inserting raw ANSI escapes
into content to force a match.

### Optional activity/mode indicators

For interfaces exposing thinking/activity levels, the current reference uses:

| Level | Color |
| --- | --- |
| Off | `inactive` |
| Minimal | `text-muted` |
| Low | `magenta` |
| Medium | `blue` |
| High | `magenta` |
| Extra high | `pink` |
| Maximum | `red` |

This is a categorical mapping, not a brightness scale. A shell-command mode
indicator uses `yellow`. Tools without these concepts can omit these roles.

## Typography and terminal background

The shared Ghostty configuration is the reference for typography:

- **JetBrains Mono Nerd Font** (Ghostty family `JetBrainsMono Nerd Font`), size **16**.
  Installed with Homebrew's `font-jetbrains-mono-nerd-font` cask; not vendored.
- Normal text: **Medium**; italic text: **Medium Italic**.
- Bold and bold-italic use their normal bold faces, not a forced Medium weight.
- Contextual alternates (`calt`) and ligatures (`liga`) enabled.
- Opaque terminal window (`background-opacity = 1`), no blur.
- Wallpaper fitted to cover, with image opacity **0.05**.

“Transparent” application backgrounds mean using the terminal's existing
background, not making the macOS window transparent. Wallpaper images remain
local, outside Git, in `~/Pictures/Wallpapers`.

The bundled install now requests the Nerd Font variant for prompt/editor glyphs.
If symbols still render as boxes, confirm the font installed and Ghostty reloaded
with the requested family rather than changing the palette.

## Shell banner: separate Nord palette

The shell's Starship banner intentionally retains its **Nord** colors. It does
not need to be recolored to Tokyo Night to follow the rest of this guide.

| Section / detail | Foreground | Background |
| --- | --- | --- |
| Username | `#ECEFF4` | `#5E81AC` |
| Folder path | `#2E3440` | `#88C0D0` |
| Git branch | `#A3BE8C` | `#2E3440` |
| Git status | `#88C0D0` | `#2E3440` |

### Powerline separator rule

Every visible section ends with a right-pointing triangle (``):

1. The triangle's **foreground is the background of the section it ends**.
2. If another visible section follows, the triangle's **background is that next
   section's background**.
3. If nothing follows, the triangle has **terminal-default/transparent background**.
4. Hidden/empty sections must not leave an empty colored block or extra triangle.

For the current username → folder → optional Git banner:

- Username triangle: foreground `#5E81AC`, background `#88C0D0`.
- Folder triangle outside Git: foreground `#88C0D0`, transparent background.
- Folder triangle with Git content: foreground `#88C0D0`, background `#2E3440`.
- Final Git triangle: foreground `#2E3440`, transparent background.

This is the desired general rule for future sections too; application-specific
configuration must implement it explicitly rather than assuming automatic layout.

## Neovim implementation: Midnight Moon

The dotfiles Neovim preset implements this guide in
`nvim/.config/nvim/lua/config/theme.lua`, loaded by the Tokyo Night plugin spec in
`lua/plugins/transparency.lua`. It keeps the upstream Moon base and plugin
integrations; it is a customization preset, not a separate `:colorscheme` name.

The main buffer and sidebars stay transparent. Floats, completion menus, status
lines, and cursor-line backgrounds use `surface` (`#1E2030`) for a darker, quieter
look, while selections use `surface-highlight`. Syntax overrides align keywords
with magenta, strings with pink, functions with the custom blue, and types with
yellow. Common LSP semantic-token groups are included so language servers do not
immediately undo those choices. Language/plugin-specific groups may still need
small follow-up adjustments after visual inspection.

## Porting to another tool

1. Use built-in theme customization if available. Do not copy another assistant's
   settings, extensions, sessions, or credentials just to reproduce its colors.
2. Map semantic roles from this document to the destination's supported tokens.
3. Preserve pink/magenta as the primary visual identity and `#73B9F8` as blue.
4. Keep the main background terminal-default when supported. Use `#222436` when
   a concrete page/background color is required; use `surface` for cards and
   `surface-highlight` for info/selected panels.
5. Preserve error/warning and diff semantics even if only a small palette is exposed.
6. Check body text, comments, selections, and search matches on the actual display.
   Dim colors are deliberately subdued and are not guaranteed to meet accessibility
   contrast targets. Brighten them locally if they are hard to read.
7. If the tool cannot expose these colors, choose its closest supported dark theme
   rather than promising an exact match through shell/terminal settings alone.

### Quick visual check

Preview a heading, ordinary paragraph, inline code, numbered list, syntax-highlighted
code block, link, successful tool panel, failed tool panel, and added/removed diff.
Also check the prompt both inside and outside a Git repository: only the final
visible triangle should have a transparent background.
