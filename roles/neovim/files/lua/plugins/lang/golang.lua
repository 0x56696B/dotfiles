vim.filetype.add { extension = { templ = 'templ' } }

return {
  { import = 'lazyvim.plugins.extras.lang.go' },

  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'vrischmann/tree-sitter-templ',
    },
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        'templ',
      })
    end,
  },

  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        templ = {},
      },
    },
  },
}
