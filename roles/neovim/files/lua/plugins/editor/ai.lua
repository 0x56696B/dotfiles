return {
  { import = "lazyvim.plugins.extras.ai.avante" },

  {
    "yetone/avante.nvim",
    dependencies = {
      -- Dependency for the input
      "folke/snacks.nvim",
    },
    opts = {
      input = {
        provider = "snacks",
        provider_opts = {
          -- Snacks input configuration
          title = "Avante Input",
          icon = " ",
          placeholder = "Enter your API key...",
        },
      },
    },
  },

  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>a", group = "ai" },
      },
    },
  },
}
