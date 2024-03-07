-- NOTE: Disabled
if true then
  return {}
end

--TODO: Add slither: https://github.com/crytic/slither
--TODO: Integrate solc-select: https://github.com/crytic/solc-select
local function findElementWithType(elements, targetType)
  for _, element in ipairs(elements) do
    if element.type == targetType then
      return element
    end
  end
  return nil
end

local function parseDiagnostic(detector)
  local severities = {
    ["High"] = vim.diagnostic.severity.ERROR,
    ["Low"] = vim.diagnostic.severity.WARN,
    ["Informational"] = vim.diagnostic.severity.INFO,
  }
  local lnum = 0
  local end_lnum = 0
  local col = 0
  local end_col = 0
  local severity = "Informational"
  local message = ""

  --   local node_element = findElementWithType(item.elements, "node")
  --   if node_element == nil then
  --     goto continue
  --   end
  --
  --   vim.print(node_element)
  --   local lines = node_element.source_mapping.lines
  --   local lnum = lines[1] - 1
  --   local end_lnum = lines[#lines] - 1
  --
  --   table.insert(diagnostics, {
  --     source = "slither",
  --     lnum = lnum,
  --     end_lnum = end_lnum,
  --     col = 0,
  --     end_col = 0,
  --     severity = severities[item.impact:lower()],
  --     message = item.description,
  --   })

  return {
    source = "slither",
    lnum = lnum,
    end_lnum = end_lnum,
    col = col,
    end_col = end_col,
    severity = severities[severity:lower()],
    message = message,
  }
end

local M = {
  -- Syntax Highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "solidity",
      })
    end,
  },

  -- LSP Server
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "nomicfoundation-solidity-language-server",
        "solhint",
        "prettier",
        --TODO: Additionally, some plugins must also be installed for prettier:
        -- `npm install --save-dev prettier-plugin-solidity`
        -- `npm install --save-dev solhint-community solhint-plugin-prettier`
      })
    end,
  },

  -- LSP Server Configuration
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        solidity_ls_nomicfoundation = {},
      },
    },
  },

  -- Formatter
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        solidity = { "prettier" },
      },
      formatters = {
        prettier = {
          prepend_args = { "--plugin=prettier-plugin-solidity" },
        },
      },
    },
  },

  -- Linter
  {
    "mfussenegger/nvim-lint",
    event = "LazyFile",
    opts = {
      linters_by_ft = {
        solidity = { "solhint", "slither" },
      },
      --NOTE: Requires slither installed locally and in $PATH
      --NOTE: pipx install slither-analyzer
      --NOTE: pipx install solc-select
      linters = {
        slither = {
          cmd = "slither",
          stdin = false,
          append_fname = false,
          args = {
            "--ignore-compile",
            "--skip-clean",
            "--disable-color",
            "--npx-disable",
            "--solc-disable-warnings",
            "--fail-none",
            "--json",
            "-",
            function()
              -- return vim.fn.getcwd()
              return "."
            end,
          },
          stream = "both",
          ignore_exitcode = true,
          env = nil,
          parser = function(output, bufnr)
            if output == "" then
              return {}
            end

            local json = vim.json.decode(output)
            if json == nil or not json.results.detectors then
              return {}
            end

            local diagnostics = {}
            for _, item in ipairs(json.results.detectors) do
              local diagnostic = parseDiagnostic(item)
              table.insert(diagnostics, diagnostic)
            end

            return diagnostics
          end,
          -- LazyVim specific function
          condition = function(ctx)
            return vim.fn.match(ctx.filename, "\\.sol$") > -1
          end,
        },
      },
    },
  },
}

return M
