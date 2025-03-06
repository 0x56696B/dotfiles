local treesitter = { 'css', 'scss' }
local mason = {
  'biome',
  'prettier',
}

vim.filetype.add({
  extension = {
    pcss = 'css',
  },
})

return {
  { import = 'lazyvim.plugins.extras.lang.tailwind' },

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
}
