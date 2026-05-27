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

      {
        "<F5>",
        function()
          require("dap").continue()
        end,
        desc = "Debug: Continue",
      },
      {
        "<F10>",
        function()
          require("dap").step_over()
        end,
        desc = "Debug: Step Over",
      },
      {
        "<F11>",
        function()
          require("dap").step_into()
        end,
        desc = "Debug: Step Into",
      },
      {
        "<S-F11>",
        function()
          require("dap").step_out()
        end,
        desc = "Debug: Step Out",
      },
      {
        "<F9>",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Debug: Toggle Breakpoint",
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
