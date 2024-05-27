local mason = {
  'biome',
  'prettier',
  'json-lsp'
}

return {
  { import = 'lazyvim.plugins.extras.lang.json' },

  {
    'williamboman/mason.nvim',
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, mason)
    end,
  },

  -- Formatter
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        ['json'] = { { 'biome', 'prettier' } },
        ['jsonc'] = { { 'biome', 'prettier' } },
        ['yaml'] = { { 'biome', 'prettier' } },
      },
    },
  },
}
