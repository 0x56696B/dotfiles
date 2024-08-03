local rust_group = vim.api.nvim_create_augroup('Rust', { clear = true })

-- Set indentation settings for Rust files
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'rust',
  callback = function()
    vim.bo.shiftwidth = 2
    vim.bo.softtabstop = 2
    vim.bo.expandtab = true
  end,
  group = rust_group,
})

return {
  { import = 'lazyvim.plugins.extras.lang.rust' },

  {
    'williamboman/mason.nvim',
    opts = {
      ensure_installed = "rust_analyzer"
    }
    -- opts = function(_, opts)
    --   opts.ensure_installed = opts.ensure_installed or {}
    --   vim.list_extend(opts.ensure_installed, '')
    -- end,
  },

  -- NOTE: Install rust-analyzer manually:
  -- `rustup component add rust-analyzer`
  {
    'neovim/nvim-lspconfig',
    opts = {
      setup = {
        -- Prevent lspconfig from setting up rust-analyzer, as it should be installed
        rust_analyzer = function()
          return true
        end,
      },
    },
  },
}
