local treesitter = { 'typescript', 'tsx', 'javascript', 'svelte', 'graphql' }
local mason = {
  -- Linters
  'biome',
  'prettierd',
  'eslint_d',

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

  -- Linter
  {
    'mfussenegger/nvim-lint',
    opts = {
      linters_by_ft = {
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
      },
      linters = {
        ["eslint_d"] = {
          condition = function(ctx)
            local root_dir = require("lazyvim.util.root").cwd()

            local eslint_configs = vim.fn.glob(root_dir .. "/.eslintrc*", false, true)
            return #eslint_configs > 0
          end
        }
      }
    },
  },

  -- Formatter
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        -- ['javascript'] = { { 'biome', 'prettierd' } },
        -- ['javascriptreact'] = { { 'biome', 'prettierd' } },
        -- ['typescript'] = { { 'biome', 'prettierd' } },
        -- ['typescriptreact'] = { { 'biome', 'prettierd' } },
        -- ['vue'] = { { 'biome', 'prettierd' } },

        ['javascript'] = { 'prettierd' },
        ['javascriptreact'] = { 'prettierd' },
        ['typescript'] = { 'prettierd' },
        ['typescriptreact'] = { 'prettierd' },
        ['vue'] = { 'prettierd' },
        ['svelte'] = { 'prettierd' }, -- Biome doesn't support svelte yet
      },
    },
  },

  -- Additional snippets
  -- {
  --   "L3MON4D3/LuaSnip",
  -- },

  -- Debugging (requires debugging.lua file from this config)
  {
    'mfussenegger/nvim-dap',
    opts = function()
      local dap = require("dap")
      if not dap.adapters["pwa-node"] then
        require("dap").adapters["pwa-node"] = {
          type = "server",
          host = "localhost",
          port = "${port}",
          executable = {
            command = "node",
            -- 💀 Make sure to update this path to point to your installation
            args = {
              require("mason-registry").get_package("js-debug-adapter"):get_install_path()
              .. "/js-debug/src/dapDebugServer.js",
              "${port}",
            },
          },
        }
      end

      for _, language in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
        if not dap.configurations[language] then
          dap.configurations[language] = {
            {
              type = "pwa-node",
              request = "launch",
              name = "Launch file",
              program = "${file}",
              cwd = "${workspaceFolder}",
            },
            {
              type = "pwa-node",
              request = "attach",
              name = "Attach",
              processId = require("dap.utils").pick_process,
              cwd = "${workspaceFolder}",
            },
          }
        end
      end
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
