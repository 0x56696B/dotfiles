local treesitter = { "typescript", "tsx", "javascript", "svelte", "graphql" }
local mason = {
  -- Linters
  "biome",
  "prettier",

  -- LSPs
  "angular-language-server",
  "emmet-language-server",
  "svelte-language-server",

  -- Debugger adaptors
  "js-debug-adapter",
}

vim.g.lazyvim_eslint_auto_format = true;
-- Enable the option to require a Prettier config file
-- If no prettier config file is found, the formatter will not be used
vim.g.lazyvim_prettier_needs_config = false
-- Enable this option to avoid conflicts with Prettier
vim.g.lazyvim_prettier_needs_config = true

return {
  { import = "lazyvim.plugins.extras.lang.typescript" },
  -- { import = "lazyvim.plugins.extras.lang.angular" },

  { import = "lazyvim.plugins.extras.linting.eslint" },
  { import = "lazyvim.plugins.extras.formatting.prettier" },
  { import = "lazyvim.plugins.extras.formatting.biome" },

  -- Syntax Highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, treesitter)
      end
    end,
  },

  -- Install LSPs
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, mason)
    end,
  },

  -- Configure LSPs
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        svelte = {},
        eslint = {},
        vtsls = {
          root_dir = require("lspconfig").util.find_git_ancestor
        }
      },
      setup = {
        eslint = function()
          require("lazyvim.util").lsp.on_attach(function(client)
            if client.name == "eslint" then
              client.server_capabilities.documentFormattingProvider = true
            elseif client.name == "tsserver" then
              client.server_capabilities.documentFormattingProvider = false
            end
          end)
        end,
      },
    },
  },

  -- Formatter
  -- {
  --   "stevearc/conform.nvim",
  --   opts = {
  --     formatters_by_ft = {
  --       -- ["javascript"] = { { "biome", "prettier" } },
  --       -- ["javascriptreact"] = { { "biome", "prettier" } },
  --       -- ["typescript"] = { { "biome", "prettier" } },
  --       -- ["typescriptreact"] = { { "biome", "prettier" } },
  --       -- ["vue"] = { { "biome", "prettier" } },
  --       ["javascript"] = { "prettier" },
  --       ["javascriptreact"] = { "prettier" },
  --       ["typescript"] = { "prettier" },
  --       ["typescriptreact"] = { "prettier" },
  --       ["vue"] = { "prettier" },
  --       ["svelte"] = { "prettier" }, -- Biome doesn"t support svelte yet
  --     },
  --   },
  -- },

  -- Debugger
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "mxsdev/nvim-dap-vscode-js"
    },
    opt = true
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
