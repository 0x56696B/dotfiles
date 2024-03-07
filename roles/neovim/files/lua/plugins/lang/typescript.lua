local treesitter = { 'typescript', 'tsx', 'svelte' }
local mason = {
  'biome',
  'prettierd',
  'angular-language-server',
  'emmet-language-server',
  'js-debug-adapter',
  'svelte-language-server',
}

return {
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      if type(opts.ensure_installed) == 'table' then
        vim.list_extend(opts.ensure_installed, treesitter)
      end
    end,
  },

  {
    'williamboman/mason.nvim',
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, mason)
    end,
  },

  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        biome = {},
        angularls = {},
        svelte = {},
        tsserver = {
          keys = {
            {
              '<leader>co',
              function()
                vim.lsp.buf.code_action {
                  apply = true,
                  context = {
                    only = { 'source.organizeImports.ts' },
                    diagnostics = {},
                  },
                }
              end,
              desc = 'Organize Imports',
            },
            {
              '<leader>cR',
              function()
                vim.lsp.buf.code_action {
                  apply = true,
                  context = {
                    only = { 'source.removeUnused.ts' },
                    diagnostics = {},
                  },
                }
              end,
              desc = 'Remove Unused Imports',
            },
          },
          settings = {
            typescript = {
              format = {
                indentSize = vim.o.shiftwidth,
                convertTabsToSpaces = vim.o.expandtab,
                tabSize = vim.o.tabstop,
              },
            },
            javascript = {
              format = {
                indentSize = vim.o.shiftwidth,
                convertTabsToSpaces = vim.o.expandtab,
                tabSize = vim.o.tabstop,
              },
            },
            completions = {
              completeFunctionCalls = true,
            },
            implicitProjectConfiguration = {
              checkJs = true,
            },
          },
        },
      },
    },
  },

  -- Formatter
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        ['javascript'] = { { 'biome', 'prettierd' } },
        ['javascriptreact'] = { { 'biome', 'prettierd' } },
        ['typescript'] = { { 'biome', 'prettierd' } },
        ['typescriptreact'] = { { 'biome', 'prettierd' } },
        ['vue'] = { { 'biome', 'prettierd' } },
        ['svelte'] = { 'prettierd' }, -- Biome doesn't support svelte yet
      },
    },
  },

  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'williamboman/mason.nvim',
    },
    opts = function()
      local dap = require 'dap'
      if not dap.adapters['pwa-node'] then
        require('dap').adapters['pwa-node'] = {
          type = 'server',
          host = 'localhost',
          port = '${port}',
          executable = {
            command = 'node',
            -- 💀 Make sure to update this path to point to your installation
            args = {
              require('mason-registry').get_package('js-debug-adapter'):get_install_path() .. '/js-debug/src/dapDebugServer.js',
              '${port}',
            },
          },
        }
      end
      for _, language in ipairs { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' } do
        if not dap.configurations[language] then
          dap.configurations[language] = {
            {
              type = 'pwa-node',
              request = 'launch',
              name = 'Launch file',
              program = '${file}',
              cwd = '${workspaceFolder}',
            },
            {
              type = 'pwa-node',
              request = 'attach',
              name = 'Attach',
              processId = require('dap.utils').pick_process,
              cwd = '${workspaceFolder}',
            },
          }
        end
      end
    end,
  },
}
