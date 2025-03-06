local treesitter = { "c", "cpp", "cmake" }
local mason = { "clang-format" }

return {
  { import = 'lazyvim.plugins.extras.lang.clangd' },
  { import = 'lazyvim.plugins.extras.lang.cmake' },

  -- Syntax highlighting
  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = treesitter }
  },

  -- Install LSPs and Linters
  {
    "williamboman/mason.nvim",
    opts = { ensure_installed = mason },
  },

  -- Formatter
  {
    'stevearc/conform.nvim',
    dependencies = { 'clangd_extensions.nvim', 'williamboman/mason.nvim' },
    opts = {
      formatters_by_ft = {
        c = { 'clang_format' },
        cpp = { 'clang_format' },
        objc = { 'clang_format' },
        objcpp = { 'clang_format' },
        cuda = { 'clang_format' },
        proto = { 'clang_format' },
      },
    },
  },
}
