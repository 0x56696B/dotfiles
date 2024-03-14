return {
  "debugloop/telescope-undo.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    require("telescope").setup({
      extensions = {
        undo = {},
      },
    })

    require("telescope").load_extension("undo")
  end,
  keys = {
    {
      "<leader>cu",
      function()
        require("telescope").extensions.undo.undo()
      end,
      desc = "Undo Tree",
      mode = "n",
    },
  },
}
