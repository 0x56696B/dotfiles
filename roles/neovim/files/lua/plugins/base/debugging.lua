return {
  { import = 'lazyvim.plugins.extras.dap.core' },

  {
    'mfussenegger/nvim-dap',
    keys = {
      {
        '<leader>df',
        function()
          require('dap').toggle_breakpoint()
        end,
        desc = 'Toggle Breakpoint',
      },
      {
        '<leader>dF',
        function()
          require('dap').set_breakpoint(vim.fn.input '[Condition] > ')
        end,
        desc = 'Conditional Breakpoint',
      },

      {
        '<leader>de',
        function()
          require('dapui').eval()
        end,
        desc = 'Evaluate',
        mode = { 'n', 'v' },
      },
      {
        '<leader>dE',
        function()
          require('dapui').eval(vim.fn.input '[Expression] > ')
        end,
        desc = 'Evaluate Input',
      },

      {
        '<leader>dr',
        function()
          require('dap').run_to_cursor()
        end,
        desc = 'Run to Cursor',
      },
      {
        '<leader>di',
        function()
          require('dap').step_into()
        end,
        desc = 'Step Into',
      },
      {
        '<leader>do',
        function()
          require('dap').step_over()
        end,
        desc = 'Step Over',
      },
      {
        '<leader>db',
        function()
          require('dap').step_back()
        end,
        desc = 'Step Back',
      },
      {
        '<leader>du',
        function()
          require('dap').step_out()
        end,
        desc = 'Step Out',
      },

      {
        '<leader>ds',
        function()
          require('dap').continue()
        end,
        desc = 'Start',
      },
      {
        '<leader>dc',
        function()
          require('dap').continue()
        end,
        desc = 'Continue',
      },
      {
        '<leader>dp',
        function()
          require('dap').pause.toggle()
        end,
        desc = 'Pause',
      },
      {
        '<leader>dd',
        function()
          require('dap').disconnect()
        end,
        desc = 'Disconnect',
      },
      {
        '<leader>dx',
        function()
          require('dap').terminate()
        end,
        desc = 'Terminate',
      },
      {
        '<leader>dq',
        function()
          require('dap').close()
        end,
        desc = 'Quit',
      },

      {
        '<leader>dt',
        function()
          require('dap').repl.toggle()
        end,
        desc = 'Toggle REPL',
      },
      {
        '<leader>dU',
        function()
          require('dapui').toggle()
        end,
        desc = 'Toggle UI',
      },
      {
        '<leader>dS',
        function()
          require('dap').session()
        end,
        desc = 'Get Session',
      },
      {
        '<leader>dH',
        function()
          require('dap.ui.widgets').hover()
        end,
        desc = 'Hover Variables',
      },
      {
        '<leader>dV',
        function()
          require('dap.ui.widgets').scopes()
        end,
        desc = 'Scopes',
      },
    },
  },

  -- Visual text when debugging
  {
    'theHamsta/nvim-dap-virtual-text',
    opts = {
      commented = true,
    },
  },
}
