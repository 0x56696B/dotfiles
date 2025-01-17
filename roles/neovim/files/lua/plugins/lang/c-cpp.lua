return {
  { import = 'lazyvim.plugins.extras.lang.clangd' },
  { import = 'lazyvim.plugins.extras.lang.cmake' },

  {
    'stevearc/conform.nvim',
    dependencies = { 'clangd_extensions.nvim', 'williamboman/mason.nvim' },
    opts = function()
      local opts = {
        formatters_by_ft = {
          c = { 'clang_format' },
          cpp = { 'clang_format' },
          objc = { 'clang_format' },
          objcpp = { 'clang_format' },
          cuda = { 'clang_format' },
          proto = { 'clang_format' },
        },
      }

      return opts
    end,
  },
}
