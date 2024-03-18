-- NOTE: This is the base setup for testing (and debugging integration). Adaptors are per-lang configured
return {
  -- Testing adaptors
  {
    "nvim-neotest/neotest",
    opts = {
      status = { virtual_text = true },
      output = { open_on_run = true },
      quickfix = {
        open = function()
          local status, trouble = pcall(require, "trouble.nvim")

          if status then
            trouble.open({ mode = "quickfix", focus = true })
          else
            vim.cmd("copen")
          end
        end,
      },
    },
    keys = function()
      local nt = require("neotest")

      return {
        { "<leader>tt", function() nt.run.run(vim.fn.expand("%")) end,                      desc = "Run File" },
        { "<leader>tT", function() nt.run.run(vim.loop.cwd()) end,                          desc = "Run All Test Files" },
        { "<leader>tr", function() nt.run.run() end,                                        desc = "Run Nearest" },
        { "<leader>tl", function() nt.run.run_last() end,                                   desc = "Run Last" },

        { "<leader>ts", function() nt.summary.toggle() end,                                 desc = "Toggle Summary" },
        { "<leader>tO", function() nt.output_panel.toggle() end,                            desc = "Toggle Output Panel" },

        { "<leader>to", function() nt.output.open({ enter = true, auto_close = true }) end, desc = "Show Output" },

        { "<leader>tS", function() nt.run.stop() end,                                       desc = "Stop" },
      }
    end,
    config = function(_, opts)
    end,
  },

  -- Debugging integration
  {
    "mfussenegger/nvim-dap",
    optional = true,
    keys = function()
      local nt = require("neotest")

      return {
        { "<leader>td", function() nt.run.run({ strategy = "dap" }) end, desc = "Debug Nearest" },
      }
    end
  },

  -- WhickKey integration
  {
    "folke/which-key.nvim",
    opts = {
      defaults = {
        ["<leader>t"] = { name = "+test" },
      },
    },
  },
}
