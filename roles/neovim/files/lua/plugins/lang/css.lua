local treesitter = { 'css', 'scss' }
local mason = {
  'biome',
  'prettier',
}

vim.filetype.add({
  extension = {
    pcss = 'css',
  },
})

return {
  { import = 'lazyvim.plugins.extras.lang.tailwind' },

  -- Syntax highlighting
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      if type(opts.ensure_installed) == 'table' then
        vim.list_extend(opts.ensure_installed, treesitter)
      end
    end,
  },

  {
    'williamboman/mason.nvim',
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, mason)
    end,
  },

  -- Configure LSP
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        tailwindcss = {
          filetypes_exclude = { 'markdown' },
          filetypes_include = {},
          root_dir = require('lspconfig.util').root_pattern('tailwind.config.*', 'postcss.config.*'),
        },
      },
    },
  },

  -- Formatting
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        ['css'] = { { 'biome', 'prettier' } },
        ['scss'] = { 'prettier' },
        ['less'] = { 'prettier' },
      },
    },
  },
}
