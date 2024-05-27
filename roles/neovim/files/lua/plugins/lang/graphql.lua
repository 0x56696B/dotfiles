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
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      if type(opts.ensure_installed) == 'table' then
        vim.list_extend(opts.ensure_installed, treesitter)
      end
    end,
  },

  -- Install LSPs
  {
    'williamboman/mason.nvim',
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, mason)
    end,
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
