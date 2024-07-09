return {
  { import = 'lazyvim.plugins.extras.lang.git' },

  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        bashls = {
          filetypes_exclude = { 'env' },
        },
      },
    },
  },
}
