local treesitter = { 'typescript', 'tsx', 'javascript', 'svelte', 'graphql' }
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

local inlay_hints_settings = {
  includeInlayFunctionLikeReturnTypeHints = false,
}

return {
  { import = 'lazyvim.plugins.extras.lang.typescript' },
  { import = 'lazyvim.plugins.extras.formatting.prettier' },
  { import = 'lazyvim.plugins.extras.linting.eslint' },

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
          settings = function(_, opts)
            return {
              typescript = {
                inlayHints = vim.tbl_deep_extend("force", opts.typescript.inlayHints, inlay_hints_settings),
                format = {
                  indentSize = vim.o.shiftwidth,
                  convertTabsToSpaces = vim.o.expandtab,
                  tabSize = vim.o.tabstop,
                },
              },
              javascript = {
                inlayHints = vim.tbl_deep_extend("force", opts.javascript.inlayHints, inlay_hints_settings),
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
            }
          end,
        },
      },
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

  -- Testing
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/neotest-jest',
    },
    opts = {
      adapters = {
        ['neotest-jest'] = function()
          return {
            jestCommand = 'npm test --',
            jestConfigFile = vim.fn.getcwd() .. 'jest.config.ts',
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
