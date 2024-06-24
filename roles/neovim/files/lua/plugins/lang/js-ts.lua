local treesitter = { 'typescript', 'tsx', 'javascript', 'svelte', 'graphql' }
local mason = {
  -- Linters
  'biome',
  'prettier',

  -- LSPs
  'angular-language-server',
  'emmet-language-server',
  'svelte-language-server',

  -- Debugger adaptors
  'js-debug-adapter',
}

return {
  { import = 'lazyvim.plugins.extras.lang.typescript' },
  { import = 'lazyvim.plugins.extras.lang.angular' },
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
        -- angularls = {},
        svelte = {},
        -- vtsls = {
        --   settings = {
        --     vtsls = {
        --       autoUseWorkspaceTsdk = true,
        --     },
        --   },
        -- },
      },
    },
  },

  -- Formatter
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        -- ['javascript'] = { { 'biome', 'prettier' } },
        -- ['javascriptreact'] = { { 'biome', 'prettier' } },
        -- ['typescript'] = { { 'biome', 'prettier' } },
        -- ['typescriptreact'] = { { 'biome', 'prettier' } },
        -- ['vue'] = { { 'biome', 'prettier' } },
        ['javascript'] = { 'prettier' },
        ['javascriptreact'] = { 'prettier' },
        ['typescript'] = { 'prettier' },
        ['typescriptreact'] = { 'prettier' },
        ['vue'] = { 'prettier' },
        ['svelte'] = { 'prettier' }, -- Biome doesn't support svelte yet
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
