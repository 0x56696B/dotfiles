return {
  -- Syntax Highlighting
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      if type(opts.ensure_installed) == 'table' then
        vim.list_extend(opts.ensure_installed, { "lua", "luadoc"})
      end
    end,
  },

  -- Install LSPs
  {
    'williamboman/mason.nvim',
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "stylua", "lua-language-server" })
    end,
  },

  -- LSP
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        lua_ls = {},
      }
    }
  }
}
