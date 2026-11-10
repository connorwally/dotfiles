return {
  -- Use Roslyn for C# language features and formatting.
  { "Hoffs/omnisharp-extended-lsp.nvim", enabled = false },
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      -- Remove the dotnet extra's CSharpier formatter. LazyVim falls back to
      -- Roslyn's LSP formatter, sharing .editorconfig with dotnet format.
      opts.formatters_by_ft.cs = {}
    end,
  },
  {
    "mason-org/mason.nvim",
    opts = {
      registries = {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry",
      },
      ensure_installed = { "roslyn" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "seblyng/roslyn.nvim",
        opts = {
          -- Let Roslyn manage its own file watching.
          filewatching = "roslyn",
        },
      },
    },
    opts = {
      -- config/autocmds.lua selectively refreshes C# diagnostics after a pause.
      diagnostics = { update_in_insert = false },
      servers = {
        omnisharp = { enabled = false },
        roslyn = {
          -- Installed through the custom Mason registry, not mason-lspconfig.
          mason = false,
          cmd_env = {
            -- Do not leave the shared daemon running after the last client exits.
            ROSLYN_LANGUAGE_SERVER_DAEMON_KEEPALIVE = "0",
          },
          settings = {
            ["csharp|completion"] = {
              dotnet_show_completion_items_from_unimported_namespaces = true,
            },
            ["csharp|background_analysis"] = {
              ["background_analysis.dotnet_analyzer_diagnostics_scope"] = "openFiles",
              ["background_analysis.dotnet_compiler_diagnostics_scope"] = "openFiles",
            },
            ["csharp|code_lens"] = {
              dotnet_enable_references_code_lens = false,
              dotnet_enable_tests_code_lens = false,
            },
          },
        },
      },
    },
  },
}
