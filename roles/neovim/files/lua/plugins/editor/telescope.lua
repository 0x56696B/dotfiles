return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    'nvim-lua/plenary.nvim'
  },
--  keys = function(_, opts)
--    local ts = require("telescope.builtin")
--
--    local config = {
--      { "<leader>ff", function() ts.git_files({ cwd = vim.loop.cwd() }) end, desc = "Find Files (root dir)" }
--    }
--
--    -- vim.print(opts)
--    opts = vim.tbl_deep_extend("force", config, opts or {})
--    vim.print(opts)
--  end,
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
