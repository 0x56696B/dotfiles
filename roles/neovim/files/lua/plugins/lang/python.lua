local treesitter = { "python" }

vim.g.lazyvim_python_lsp = "basedpyright"

return {
  { import = "lazyvim.plugins.extras.lang.python" },

  -- Syntax Highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = treesitter },
  },
}
