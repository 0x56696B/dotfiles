local treesitter = { 'css', 'scss' }
local mason = {
  'biome',
  'prettierd',
}

return {
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

  -- Formatting
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        ['css'] = { { 'biome', 'prettierd' } },
        ['scss'] = { 'prettierd' },
        ['less'] = { 'prettierd' },
        ['html'] = { { 'biome', 'prettierd' } },
      },
    },
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tailwindcss = {
          filetypes_exclude = { "markdown" },
          filetypes_include = {},
          root_dir = require("lspconfig.util").root_pattern('tailwind.config.*', 'postcss.config.*')
        }
      },
    },
  },

  -- AutoComplete
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      { "roobert/tailwindcss-colorizer-cmp.nvim", config = true },
    },
    -- opts = function(_, opts)
    --   local format_kinds = opts.formatting.format
    --   opts.formatting.format = function(entry, item)
    --     format_kinds(entry, item)
    --     return require("tailwindcss-colorizer-cmp").formatter(entry, item)
    --   end
    -- end,
  },
}
