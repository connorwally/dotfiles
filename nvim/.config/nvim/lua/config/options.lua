-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Use the native number gutter with no separate sign/icon padding.
-- Diagnostic/Git signs replace the number on their line rather than adding width.
vim.opt.numberwidth = 2
vim.opt.signcolumn = "number"
vim.opt.foldcolumn = "0"
vim.opt.statuscolumn = ""

-- Visually wrap long lines at word boundaries.
vim.opt.wrap = true
vim.opt.linebreak = true
