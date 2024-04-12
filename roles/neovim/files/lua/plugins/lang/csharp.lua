return {
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      if type(opts.ensure_installed) == 'table' then
        vim.list_extend(opts.ensure_installed, { 'c_sharp' })
      end
    end,
  },

  {
    'williamboman/mason.nvim',
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { 'omnisharp', 'omnisharp-mono', 'netcoredbg', 'csharpier' }) --, 'csharp-language-server' })
    end,
  },

  -- { 'jmederosalvarado/roslyn.nvim', opts = {} },

  {
    'neovim/nvim-lspconfig',
    -- ft = { 'cs', 'csproj', 'sln', 'razor' },
    dependencies = {
      { 'Hoffs/omnisharp-extended-lsp.nvim', lazy = true },
    },
    opts = {
      servers = {
        omnisharp = {
          handlers = {
            ['textDocument/definition'] = function()
              return require('omnisharp_extended').handler
            end,
          },
          keys = {
            {
              'gd',
              function()
                require('omnisharp_extended').telescope_lsp_definitions()
              end,
              desc = 'Goto Definition',
            },
          },
          enable_roslyn_analyzers = true,
          organize_imports_on_format = false,
          enable_import_completion = true,
          enable_editorconfig_support = true,
          enable_ms_build_load_projects_on_demand = false, -- When true, it's useful for big projects, but might not yield full autocompletion
        },
      },
    },
  },

  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        cs = { 'csharpier' },
        csproj = { 'csharpier' },
        sln = { 'csharpier' },
      },
      formatters = {
        csharpier = {
          command = 'dotnet-csharpier',
          args = { '--write-stdout' },
        },
      },
    },
  },

  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'theHamsta/nvim-dap-virtual-text',
    },
    opts = {
      adapters = {
        ['coreclr'] = {
          type = 'executable',
          command = vim.fn.stdpath('data') .. '/mason/packages/netcoredbg',
          args = { '--interpreter=vscode' },
        },
        ['netcoredbg'] = {
          args = { '--interpreter=vscode' }
        },
      },
      configurations = {
        ['cs'] = {
          type = 'coreclr',
          name = 'launch - netcoredbg',
          request = 'launch',
          program = function()
            return vim.fn.input('Path to dll', vim.fn.getcwd() .. '/bin/Debug/', 'file')
          end,
        },
      },
    },
  },
}
