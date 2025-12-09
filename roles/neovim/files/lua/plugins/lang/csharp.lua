local treesitter = { "c_sharp", "razor" }
local mason = {
  -- Linters
  "csharpier",

  -- LSPs
  "roslyn",
  "rzls",
  "html-lsp",

  -- Debug Addaptors
  "netcoredbg",
}

return {
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
    "mason-org/mason.nvim",
    opts = function(_, opts)
      local default_registries = require("mason.settings").current.registries or {}
      opts.registries = vim.list_extend(default_registries, { "github:crashdummyy/mason-registry" })

      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, mason)

      return opts
    end,
  },

  -- Configure Roslyn
  {
    "seblyng/roslyn.nvim",
    ft = { "cs", "razor" },
    version = "*",
    dependencies = {
      {
        -- By loading as a dependencies, we ensure that we are available to set
        -- the handlers for roslyn
        "tris203/rzls.nvim",
        config = function()
          ---@diagnostic disable-next-line: missing-fields
          require("rzls").setup {}
        end,
      },
    },
    opts = {
      config = {
        settings = {
          ["csharp|inlay_hints"] = {
            csharp_enable_inlay_hints_for_implicit_object_creation = true,
            csharp_enable_inlay_hints_for_implicit_variable_types = true,

            csharp_enable_inlay_hints_for_lambda_parameter_types = true,
            csharp_enable_inlay_hints_for_types = true,
            dotnet_enable_inlay_hints_for_indexer_parameters = true,
            dotnet_enable_inlay_hints_for_literal_parameters = true,
            dotnet_enable_inlay_hints_for_object_creation_parameters = true,
            dotnet_enable_inlay_hints_for_other_parameters = true,
            dotnet_enable_inlay_hints_for_parameters = true,
            dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
            dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
            dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
          },
          ["csharp|code_lens"] = {
            dotnet_enable_references_code_lens = true,
          },
        },
      },
    },
    init = function()
      -- we add the razor filetypes before the plugin loads
      vim.filetype.add {
        extension = {
          razor = "razor",
          cshtml = "razor",
        },
      }
    end,
    config = function()
      require("roslyn").setup {
        -- exe = "dotnet",
        -- exe = {
        --   "dotnet",
        --   vim.fs.joinpath(vim.fn.stdpath("data") --[[@as string]], "roslyn", "Microsoft.CodeAnalysis.LanguageServer.dll"),
        -- },
        exe = vim.fs.joinpath(vim.fn.stdpath "data" --[[@as string]], "roslyn", "Microsoft.CodeAnalysis.LanguageServer.dll"),
        args = {
          "--stdio",
          "--logLevel=Information",
          "--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.get_log_path()),
          "--razorSourceGenerator="
            .. vim.fs.joinpath(vim.fn.stdpath "data" --[[@as string]], "mason", "packages", "roslyn", "libexec", "Microsoft.CodeAnalysis.Razor.Compiler.dll"),
          "--razorDesignTimePath=" .. vim.fs.joinpath(
            vim.fn.stdpath "data" --[[@as string]],
            "mason",
            "packages",
            "rzls",
            "libexec",
            "Targets",
            "Microsoft.NET.Sdk.Razor.DesignTime.targets"
          ),
        },
        ---@diagnostic disable-next-line: missing-fields
        config = {
          handlers = require "rzls.roslyn_handlers",
        },
      }
    end,
  },

  -- Formatter
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        cs = { "csharpier" },
      },
      formatters = {
        csharpier = {
          command = "dotnet-csharpier",
          args = { "--write-stdout" },
        },
      },
    },
  },

  -- Debugging
  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function()
      local dap = require "dap"
      if not dap.adapters["netcoredbg"] then
        require("dap").adapters["netcoredbg"] = {
          type = "executable",
          command = vim.fn.exepath "netcoredbg",
          args = { "--interpreter=vscode" },
          options = {
            detached = false,
          },
        }
      end
      for _, lang in ipairs { "cs", "fsharp", "vb" } do
        if not dap.configurations[lang] then
          dap.configurations[lang] = {
            {
              type = "netcoredbg",
              name = "Launch file",
              request = "launch",
              ---@diagnostic disable-next-line: redundant-parameter
              program = function()
                return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/", "file")
              end,
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
    optional = true,
    dependencies = {
      "Issafalcon/neotest-dotnet",
    },
    opts = {
      adapters = {
        ["neotest-dotnet"] = {
          -- Here we can set options for neotest-dotnet
        },
      },
    },
  },

  -- Fixes
  {
    "folke/trouble.nvim",
    opts = {
      modes = {
        -- Exclude the virtual buffers from diagnostics
        diagnostics = {
          filter = function(items)
            return vim.tbl_filter(function(item)
              return not string.match(item.basename, [[%__virtual.cs$]])
            end, items)
          end,
        },
      },
    },
  },
}
