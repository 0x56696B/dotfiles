local treesitter = { "rust" }

local rust_group = vim.api.nvim_create_augroup("Rust", { clear = true })

-- Set indentation settings for Rust files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function()
    vim.bo.shiftwidth = 2
    vim.bo.softtabstop = 2
    vim.bo.expandtab = true
  end,
  group = rust_group,
})

return {
  { import = "lazyvim.plugins.extras.lang.rust" },

  -- Syntax Highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = treesitter },
  },

  -- NOTE: Install rust-analyzer manually:
  -- `rustup component add rust-analyzer`
  -- Configure LSP
  {
    "neovim/nvim-lspconfig",
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
