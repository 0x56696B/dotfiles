-- NOTE: This is the base setup for testing (and debugging integration). Adaptors are per-lang configured
return {
  -- Testing adaptors
  {
    "nvim-neotest/neotest",
    lazy = true,
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
    keys = {
      { "<leader>tt", function() require('neotest').run.run(vim.fn.expand("%")) end,                      desc = "Run File" },
      { "<leader>tT", function() require('neotest').run.run(vim.loop.cwd()) end,                          desc = "Run All Test Files" },
      { "<leader>tr", function() require('neotest').run.run() end,                                        desc = "Run Nearest" },
      { "<leader>tl", function() require('neotest').run.run_last() end,                                   desc = "Run Last" },

      { "<leader>ts", function() require('neotest').summary.toggle() end,                                 desc = "Toggle Summary" },
      { "<leader>tO", function() require('neotest').output_panel.toggle() end,                            desc = "Toggle Output Panel" },

      { "<leader>to", function() require('neotest').output.open({ enter = true, auto_close = true }) end, desc = "Show Output" },

      { "<leader>tS", function() require('neotest').run.stop() end,                                       desc = "Stop" },
    },
    config = function(_, opts)
    end,
  },

  -- Debugging integration
  {
    "mfussenegger/nvim-dap",
    optional = true,
    deependencies = {
      "nvim-neotest/neotest",
    },
    keys = {
      { "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Debug Nearest" },
    }
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
