-- NOTE: This is the base setup for debugging. Adaptors are per-lang configured
return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'theHamsta/nvim-dap-virtual-text',
      'nvim-telescope/telescope-dap.nvim',
    },
    keys = function()
      local dap = require('dap')
      local ui = require('dapui')
      local widgets = require('dap.ui.widgets')

      return {
        { '<leader>df', function() dap.toggle_breakpoint() end,                           desc = 'Toggle Breakpoint', },
        { '<leader>dF', function() dap.set_breakpoint(vim.fn.input '[Condition] > ') end, desc = 'Conditional Breakpoint', },

        { '<leader>de', function() ui.eval() end,                                         desc = 'Evaluate',               mode = { 'n', 'v' }, },
        { '<leader>dE', function() ui.eval(vim.fn.input '[Expression] > ') end,           desc = 'Evaluate Input', },

        { '<leader>dr', function() dap.run_to_cursor() end,                               desc = 'Run to Cursor', },
        { '<leader>di', function() dap.step_into() end,                                   desc = 'Step Into', },
        { '<leader>do', function() dap.step_over() end,                                   desc = 'Step Over', },
        { '<leader>db', function() dap.step_back() end,                                   desc = 'Step Back', },
        { '<leader>du', function() dap.step_out() end,                                    desc = 'Step Out', },

        { '<leader>ds', function() dap.continue() end,                                    desc = 'Start', },
        { '<leader>dc', function() dap.continue() end,                                    desc = 'Continue', },
        { '<leader>dp', function() dap.pause.toggle() end,                                desc = 'Pause', },
        { '<leader>dd', function() dap.disconnect() end,                                  desc = 'Disconnect', },
        { '<leader>dx', function() dap.terminate() end,                                   desc = 'Terminate', },
        { '<leader>dq', function() dap.close() end,                                       desc = 'Quit', },

        { '<leader>dt', function() dap.repl.toggle() end,                                 desc = 'Toggle REPL', },
        { '<leader>dU', function() ui.toggle() end,                                       desc = 'Toggle UI', },
        { '<leader>dS', function() dap.session() end,                                     desc = 'Get Session', },
        { '<leader>dH', function() widgets.hover() end,                                   desc = 'Hover Variables', },
        { '<leader>dV', function() widgets.scopes() end,                                  desc = 'Scopes', },
      }
    end,
    config = function(_, opts)
    end
  },

  -- Debugging UI
  {
    'rcarriga/nvim-dap-ui',
    config = function(_, opts)
      local dap = require("dap")
      local ui = require("dapui")

      dap.listeners.after.event_initialized["dapui_config"] = function()
        ui.open({})
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        ui.close({})
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        ui.close({})
      end
    end
  },

  -- Visual text when debugging
  {
    'theHamsta/nvim-dap-virtual-text',
    opts = {
      commented = true,
    }
  },

  -- Telescope integration
  {
    'nvim-telescope/telescope-dap.nvim',
    dependencies = {
      'nvim-telescope/telescope.nvim',
    },
    keys = function()
      local dap_ext = require('telescope').extensions.dap

      return {
        { '<leader>dC', function() dap_ext.configurations {} end, desc = 'Configurations', },
      }
    end,
    config = function()
      require("telescope").setup({
        extensions = {
          dap = {},
        },
      })
    end
  },

  -- WhickKey integration
  {
    'folke/which-key.nvim',
    opts = {
      defaults = {
        ['<leader>d'] = { name = '+debug' },
      },
    },
  },
}
