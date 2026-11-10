-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- C# fallback defaults. Native EditorConfig runs after FileType and applies
-- project overrides (including closer/nested .editorconfig files) afterward.
local csharp_editing_group = vim.api.nvim_create_augroup("csharp_editing", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = csharp_editing_group,
  pattern = "cs",
  callback = function(event)
    -- Also preserve properties if FileType is triggered again after EditorConfig.
    local ec = vim.b[event.buf].editorconfig
    ec = type(ec) == "table" and ec or {}
    if not ec.indent_style then
      vim.bo[event.buf].expandtab = true
    end
    if not ec.tab_width and not ec.indent_size then
      vim.bo[event.buf].tabstop = 4
    end
    if not ec.indent_size then
      vim.bo[event.buf].shiftwidth = 4
    end
    -- Follow shiftwidth, including subsequent EditorConfig changes.
    vim.bo[event.buf].softtabstop = -1

    vim.keymap.set("i", "<BS>", function()
      if vim.api.nvim_get_current_line():match("^%s*$") then
        -- Delete the blank line without overwriting the yank/delete registers.
        return vim.api.nvim_replace_termcodes('<C-o>"_dd', true, false, true)
      end
      -- Preserve LazyVim's paired-bracket deletion on nonblank lines.
      if _G.MiniPairs then
        return MiniPairs.bs()
      end
      return vim.api.nvim_replace_termcodes("<BS>", true, false, true)
    end, {
      buffer = event.buf,
      expr = true,
      replace_keycodes = false,
      desc = "Delete blank line or backspace",
    })
  end,
})

-- Use Roslyn's advertised triggers (including ; and }) for targeted formatting.
-- Roslyn also handles whole-file formatting on save and with <leader>cf.
vim.api.nvim_create_autocmd("LspAttach", {
  group = csharp_editing_group,
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client.name == "roslyn" and vim.bo[event.buf].filetype == "cs" then
      vim.lsp.on_type_formatting.enable(true, { client_id = client.id })
    end
  end,
})

-- A fix in another file can invalidate this buffer's cached diagnostics even
-- though its text hasn't changed. Pull fresh results when returning to it.
vim.api.nvim_create_autocmd("BufEnter", {
  group = csharp_editing_group,
  callback = function(event)
    if vim.bo[event.buf].filetype ~= "cs" then
      return
    end
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(event.buf)
        or event.buf ~= vim.api.nvim_get_current_buf() then
        return
      end
      for _, client in ipairs(vim.lsp.get_clients({
        bufnr = event.buf,
        name = "roslyn",
        method = "textDocument/diagnostic",
      })) do
        -- This private helper is version-dependent; skip if unavailable.
        if vim.lsp.diagnostic._refresh then
          vim.lsp.diagnostic._refresh(event.buf, client.id)
        end
      end
    end)
  end,
})

-- Keep normal diagnostic updates deferred in Insert mode, but display the
-- latest C# diagnostics after typing (and incoming diagnostics) settle.
local diagnostic_group = vim.api.nvim_create_augroup("csharp_diagnostic_pause", { clear = true })
local diagnostic_generation = 0

vim.api.nvim_create_autocmd({ "InsertEnter", "TextChangedI", "TextChangedP", "DiagnosticChanged" }, {
  group = diagnostic_group,
  callback = function(event)
    if event.buf ~= vim.api.nvim_get_current_buf()
      or vim.bo[event.buf].filetype ~= "cs"
      or vim.api.nvim_get_mode().mode:sub(1, 1) ~= "i" then
      return
    end

    diagnostic_generation = diagnostic_generation + 1
    local generation = diagnostic_generation
    vim.defer_fn(function()
      if generation == diagnostic_generation
        and vim.api.nvim_buf_is_valid(event.buf)
        and event.buf == vim.api.nvim_get_current_buf()
        and vim.api.nvim_get_mode().mode:sub(1, 1) == "i" then
        vim.diagnostic.show(nil, event.buf, nil, { update_in_insert = true })
      end
    end, 750)
  end,
})

vim.api.nvim_create_autocmd({ "InsertLeave", "BufLeave" }, {
  group = diagnostic_group,
  callback = function(event)
    diagnostic_generation = diagnostic_generation + 1
    if event.event == "InsertLeave" and vim.bo[event.buf].filetype == "cs" then
      vim.diagnostic.show(nil, event.buf, nil, { update_in_insert = true })
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("markdown_defaults", { clear = true }),
  pattern = "markdown",
  callback = function(event)
    vim.opt_local.wrap = true
    vim.opt_local.spell = false
    vim.diagnostic.enable(false, { bufnr = event.buf })
  end,
})
