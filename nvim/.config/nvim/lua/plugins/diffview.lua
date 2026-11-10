return {
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewFileHistory",
      "DiffviewFocusFiles",
      "DiffviewToggleFiles",
      "DiffviewRefresh",
    },
    keys = {
      { "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Diffview (All Changes vs HEAD)" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview Repository History" },
      { "<leader>gF", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview File History" },
      { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Close Diffview" },
    },
    opts = {
      default_args = {
        DiffviewOpen = { "HEAD", "--untracked-files=all", "--", "." },
      },
    },
  },
}
