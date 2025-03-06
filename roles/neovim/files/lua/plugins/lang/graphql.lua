local treesitter = { 'graphql' }
local mason = {
  -- Formatter
  'prettierd',

  -- LSPs
  'graphql-language-service-cli',
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

  -- Configure LSPs
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        graphql = {},
      },
    },
  },

  -- Formatter
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        ['gql'] = { 'prettierd' },
        ['*'] = { 'injected' },
      },
    },
  },
}
