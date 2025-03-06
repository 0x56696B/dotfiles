local treesitter = { "html" }
local mason = {
  -- LSPs
  "templ",
}

return {
  -- Syntax Highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "vrischmann/tree-sitter-templ",
    },
    opts = { ensure_installed = treesitter },
  },

  -- Install LSPs and Linters
  {
    "williamboman/mason.nvim",
    opts = { ensure_installed = mason },
  },

  -- Formatting
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        html = { "templ" },
        templ = { "templ" },
      },
    },
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        templ = {},
      },
    },
  },
}
