local treesitter = { "typescript", "tsx", "javascript", "svelte", "graphql" }
local mason = {
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
  { import = "lazyvim.plugins.extras.lang.angular" },

  { import = "lazyvim.plugins.extras.linting.eslint" },
  { import = "lazyvim.plugins.extras.formatting.prettier" },
  { import = "lazyvim.plugins.extras.formatting.biome" },

  -- Syntax Highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = treesitter },
  },

  -- Install LSPs
  {
    "williamboman/mason.nvim",
    opts = { ensure_installed = mason },
  },

  -- Configure LSPs
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        svelte = {},
        eslint = {},
        vtsls = {
          root_dir = vim.fs.dirname(vim.fs.find('.git', { path = startpath, upward = true })[1])
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
