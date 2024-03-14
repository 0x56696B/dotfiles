return {
  "nvim-telescope/telescope.nvim",
  opts = {
    mappings = {
      i = {
        ["C-c"] = "Close",
      },
      n = {
        ["C-c"] = "Close",
      },
    },
    defaults = {
      layout_strategy = "flex",
      layout_config = {
        flex = {
          flip_columns = 140,
          vertical = {
            width = 0.95,
          },
          horizontal = {
            width = 0.65,
          },
        },
      },
      path_display = {
        "truncate",
      },
    },
  },
}
