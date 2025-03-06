local treesitter = { "json" }
local mason = {
  -- LSPs
  "json-lsp",

  -- Linters
  "biome",
  "prettier",
}

return {
  { import = "lazyvim.plugins.extras.lang.json" },

  -- Syntax Highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = treesitter },
  },

  -- Install LSPs and Linters
  {
    "williamboman/mason.nvim",
    opts = { ensure_installed = mason },
  },

  -- Formatter
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        ["json"] = { "biome", "prettier" },
        ["jsonc"] = { "biome", "prettier" },
        ["yaml"] = { "biome", "prettier" },
      },
    },
  },
}
