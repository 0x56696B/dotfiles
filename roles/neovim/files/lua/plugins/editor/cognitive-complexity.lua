return {
  {
    "CrixuAMG/visual-complexity.nvim",
    event = "VeryLazy",
    config = function()
      require("visual-complexity").setup {
        enabled_filetypes = {
          "lua",
          "javascript",
          "typescript",
          "php",
        },
        -- By default, function count is hidden because it is usually 1 per method
        virtual_text_format = "Complexity: %.1f | Cond: %d",
        highlight_group = "Comment",
        show_bar = true,
        weights = {
          line = 1.0,
          func = 2.0,
          conditional = 1.5,
          indent = 0.1,
          clump = 1.0,
        },
        severity_thresholds = {
          { max = 10, group = "Comment" },
          { max = 25, group = "WarningMsg" },
          { max = math.huge, group = "ErrorMsg" },
        },
        threshold_for_warnings = 15,

        keymaps = {
          -- Global mappings (you can set these to whatever fits your setup)
          toggle_reasons = nil, -- Example: "<leader>vr"
          open_map = nil, -- Example: "<leader>vm"
          toggle_map_pin = nil, -- Example: "<leader>vP"

          -- Local mappings inside the map window
          map = {
            jump = "<CR>",
            close = "q",
            toggle_pin = "p",
          },
        },
      }
    end,
  },
}
