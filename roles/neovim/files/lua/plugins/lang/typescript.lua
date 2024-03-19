local treesitter = { 'typescript', 'tsx', 'javascript', 'svelte' }
local mason = {
  -- Linters
  'biome',
  'prettierd',

  -- LSPs
  'angular-language-server',
  'emmet-language-server',
  'svelte-language-server',

  -- Debugger adaptors
  'js-debug-adapter',
}

return {
  -- Syntax Highlighting
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      if type(opts.ensure_installed) == 'table' then
        vim.list_extend(opts.ensure_installed, treesitter)
      end
    end,
  },

  -- Install LSPs
  {
    'williamboman/mason.nvim',
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, mason)
    end,
  },

  -- Configure LSPs
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

  -- Debugging (requires debugging.lua file from this config)
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      "mxsdev/nvim-dap-vscode-js"
    },
    config = function()
      local config = {
        node_path = os.getenv('NVM_BIN') .. 'node',
        adapters = { 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost' },
        debugger_path = vim.fn.stdpath 'data' .. 'mason/bin',
        debugger_cmd = { 'js-debug-adapter' },
      }

      local dap = require("dap")
      dap.adapters["pwa-node"] = {
        type = 'server',
        host = '127.0.0.1',
        port = "${port}"
      }

      -- All debug configurations I might need, for all types of projects
      for _, language in ipairs({ 'typescript', 'javascript' }) do
        dap.configurations[language] = {
          {
            name = 'Launch Debug',
            type = 'pwa-node',
            request = 'launch',
            program = '${file}',
            rootPath = '${workspaceFolder}',
            cwd = '${workspaceFolder}',
            sourceMaps = true,
            skipFiles = { '<node_internals>/**' },
            protocol = 'inspector',
            console = 'integratedTerminal',
            hostName = "127.0.0.1",
          },
          {
            name = 'Attach to node process',
            type = 'pwa-node',
            request = 'attach',
            rootPath = '${workspaceFolder}',
            processId = require('dap.utils').pick_process,
          },
          {
            type = "pwa-node",
            request = "launch",
            name = "Debug Jest Tests",
            -- trace = true, -- include debugger info
            runtimeExecutable = "node",
            runtimeArgs = {
              "./node_modules/jest/bin/jest.js",
              "--runInBand",
            },
            rootPath = "${workspaceFolder}",
            cwd = "${workspaceFolder}",
            console = "integratedTerminal",
            internalConsoleOptions = "neverOpen",
          },
          {
            name = 'Debug Main Process (Electron)',
            type = 'pwa-node',
            request = 'launch',
            program = '${workspaceFolder}/node_modules/.bin/electron',
            args = {
              '${workspaceFolder}/dist/index.js',
            },
            outFiles = {
              '${workspaceFolder}/dist/*.js',
            },
            resolveSourceMapLocations = {
              '${workspaceFolder}/dist/**/*.js',
              '${workspaceFolder}/dist/*.js',
            },
            rootPath = '${workspaceFolder}',
            cwd = '${workspaceFolder}',
            sourceMaps = true,
            skipFiles = { '<node_internals>/**' },
            protocol = 'inspector',
            console = 'integratedTerminal',
          },
          {
            name = 'Compile & Debug Main Process (Electron)',
            type = 'pwa-node-custom',
            request = 'launch',
            preLaunchTask = 'npm run build-ts',
            program = '${workspaceFolder}/node_modules/.bin/electron',
            args = {
              '${workspaceFolder}/dist/index.js',
            },
            outFiles = {
              '${workspaceFolder}/dist/*.js',
            },
            resolveSourceMapLocations = {
              '${workspaceFolder}/dist/**/*.js',
              '${workspaceFolder}/dist/*.js',
            },
            rootPath = '${workspaceFolder}',
            cwd = '${workspaceFolder}',
            sourceMaps = true,
            skipFiles = { '<node_internals>/**' },
            protocol = 'inspector',
            console = 'integratedTerminal',
          },

        }
      end

      return config
    end,
  },

  -- Testing
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/neotest-jest",
    },
    opts = {
      adapters = {
        ["neotest-jest"] = function()
          return {
            jestCommand = "npm test --",
            jestConfigFile = vim.fn.getcwd() .. "jest.config.ts",
            env = { CI = true },
            cwd = function()
              return vim.fn.getcwd()
            end,
          }
        end,
      },
    },
  },
}
