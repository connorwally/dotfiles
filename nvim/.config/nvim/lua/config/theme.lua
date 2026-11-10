-- Midnight Moon: a Tokyo Night Moon preset aligned with STYLE-GUIDE.md.
-- Keep upstream plugin integrations; customize the palette and semantic roles.
local palette = {
  background = "#222436",
  surface = "#1e2030",
  selection = "#2f334d",
  text = "#c8d3f5",
  muted = "#828bb8",
  border = "#3b4261",
  comment = "#636da6",
  blue = "#73b9f8",
  cyan = "#86e1fc",
  teal = "#4fd6be",
  magenta = "#c099ff",
  pink = "#fca7ea",
  orange = "#ff966c",
  red = "#ff757f",
  yellow = "#ffc777",
  added = "#b8db87",
  removed = "#e26a75",
  search = "#3d3548",
}

return {
  style = "moon",
  transparent = true,
  styles = {
    sidebars = "transparent",
    floats = "dark",
  },
  on_colors = function(c)
    c.bg = palette.background
    c.bg_dark = palette.surface
    c.bg_float = palette.surface
    c.bg_popup = palette.surface
    c.bg_statusline = palette.surface
    c.bg_highlight = palette.surface
    c.bg_visual = palette.selection
    c.bg_search = palette.search
    c.fg = palette.text
    c.fg_dark = palette.muted
    c.comment = palette.comment
    c.blue = palette.blue
    c.border = palette.border
    c.border_highlight = palette.magenta
    c.error = palette.red
    c.hint = palette.magenta
    c.git.add = palette.added
    c.git.delete = palette.removed
    -- Tokyo Night derives terminal colors before calling on_colors.
    c.terminal.blue = palette.blue
  end,
  on_highlights = function(hl)
    local function color(groups, fg, extra)
      for _, group in ipairs(groups) do
        hl[group] = vim.tbl_extend("force", { fg = fg }, extra or {})
      end
    end

    color(
      {
        "Keyword",
        "Statement",
        "Conditional",
        "Repeat",
        "Exception",
        "StorageClass",
        "PreProc",
        "Include",
        "Define",
        "Macro",
        "Debug",
      },
      palette.magenta
    )
    color(
      {
        "@keyword",
        "@keyword.function",
        "@keyword.conditional",
        "@keyword.repeat",
        "@keyword.exception",
        "@keyword.import",
        "@keyword.directive",
        "@keyword.directive.define",
        "@keyword.storage",
        "@keyword.coroutine",
        "@keyword.return",
        "@keyword.debug",
        "@lsp.type.keyword",
        "@lsp.type.modifier",
        "@lsp.type.selfKeyword",
        "@lsp.type.selfTypeKeyword",
      },
      palette.magenta,
      { italic = true }
    )
    color(
      { "String", "Character", "@string", "@string.documentation", "@string.regexp", "@markup.raw.markdown_inline" },
      palette.pink
    )
    color({ "Function", "@function", "@function.builtin", "@function.method" }, palette.blue)
    color(
      {
        "Identifier",
        "@variable",
        "@variable.member",
        "@variable.parameter",
        "@variable.parameter.builtin",
        "@property",
      },
      palette.text
    )
    color(
      {
        "Type",
        "Typedef",
        "@type",
        "@type.builtin",
        "@type.definition",
        "@lsp.type.interface",
        "@lsp.typemod.type.defaultLibrary",
        "@lsp.typemod.typeAlias.defaultLibrary",
      },
      palette.yellow
    )
    color({ "Number", "Float", "Boolean", "@markup.list", "@markup.list.markdown" }, palette.orange)
    color(
      { "Operator", "Delimiter", "@operator", "@punctuation.bracket", "@punctuation.delimiter", "@punctuation.special" },
      palette.cyan
    )
    color({ "Title", "FloatTitle", "@markup.heading" }, palette.magenta, { bold = true })
    for level = 1, 6 do
      color({ "@markup.heading." .. level .. ".markdown" }, palette.magenta, { bold = true })
    end
    color({ "@markup.link", "@markup.link.label" }, palette.cyan)
    color({ "@markup.link.url" }, palette.teal, { underline = true })
    color({ "@markup.quote" }, palette.muted)
    color({ "healthSuccess", "@markup.list.checked" }, palette.pink)

    hl.Search = { fg = palette.yellow, bg = palette.search }
    hl.IncSearch = { fg = palette.background, bg = palette.yellow }
    hl.PmenuSel = { fg = palette.text, bg = palette.selection }
    hl.PmenuMatch = { fg = palette.pink, bg = palette.surface }
    hl.PmenuMatchSel = { fg = palette.pink, bg = palette.selection }
    hl.CursorLineNr = { fg = palette.pink, bold = true }
    hl.MatchParen = { fg = palette.pink, bold = true }
  end,
}
