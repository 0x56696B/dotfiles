local treesitter = { "terraform" }
local mason = {
  -- LSPs
  "terraform-ls",

  -- Linters
  "tflint",
}

return {
  { import = "lazyvim.plugins.extras.lang.terraform" },

  -- Syntax Highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = treesitter },
  },

  -- Install LSPs and Linters
  {
    "williamboman/mason.nvim",
    opts = { ensure_installed = mason },
  },
}
