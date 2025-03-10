local treesitter = { "go", "templ", "gotmpl" }
local mason = {
  -- LSPs
  "templ",
}

vim.filetype.add {
  extension = {
    templ = "templ",
  },
}

return {
  { import = "lazyvim.plugins.extras.lang.go" },

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

  -- Configure LSPs
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        templ = {},
      },
    },
  },
}
