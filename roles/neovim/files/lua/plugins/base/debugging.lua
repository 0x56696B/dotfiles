return {
  { import = "lazyvim.plugins.extras.dap.core" },

  {
    "mfussenegger/nvim-dap",
    keys = {
      {
        "<leader>dh",
        function()
          require("dap.ui.widgets").hover()
        end,
        desc = "Inspect value under cursor",
      },
    },
  },

  -- Visual text when debugging
  {
    "theHamsta/nvim-dap-virtual-text",
    opts = {
      commented = true,
    },
  },
}
