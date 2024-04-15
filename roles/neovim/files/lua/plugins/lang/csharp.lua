-- NOTE: Disabled
if true then
  return {}
end

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
      vim.list_extend(opts.ensure_installed, { 'omnisharp', 'omnisharp-mono', 'netcoredbg', 'csharpier' })
    end,
  },

  -- { 'jmederosalvarado/roslyn.nvim', opts = {} },

  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason-lspconfig.nvim' },
      { 'Hoffs/omnisharp-extended-lsp.nvim', lazy = true },
    },
    opts = {
      servers = {
        omnisharp = {
          handlers = {
            ["textDocument/definition"] = require('omnisharp_extended').definition_handler,
            ["textDocument/typeDefinition"] = require('omnisharp_extended').type_definition_handler,
            ["textDocument/references"] = require('omnisharp_extended').references_handler,
            ["textDocument/implementation"] = require('omnisharp_extended').implementation_handler,
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
          settings = {
            FormattingOptions = {
              -- Enables support for reading code style, naming convention and analyzer
              -- settings from .editorconfig.
              EnableEditorConfigSupport = true,
              -- Specifies whether 'using' directives should be grouped and sorted during
              -- document formatting.
              OrganizeImports = true,
            },
            MsBuild = {
              -- If true, MSBuild project system will only load projects for files that
              -- were opened in the editor. This setting is useful for big C# codebases
              -- and allows for faster initialization of code navigation features only
              -- for projects that are relevant to code that is being edited. With this
              -- setting enabled OmniSharp may load fewer projects and may thus display
              -- incomplete reference lists for symbols.
              LoadProjectsOnDemand = false,
            },
            RoslynExtensionsOptions = {
              -- Enables support for roslyn analyzers, code fixes and rulesets.
              EnableAnalyzersSupport = true,
              -- Enables support for showing unimported types and unimported extension
              -- methods in completion lists. When committed, the appropriate using
              -- directive will be added at the top of the current file. This option can
              -- have a negative impact on initial completion responsiveness,
              -- particularly for the first few completion sessions after opening a
              -- solution.
              EnableImportCompletion = true,
              -- Only run analyzers against open files when 'enableRoslynAnalyzers' is
              -- true
              AnalyzeOpenDocumentsOnly = nil,
            },
            Sdk = {
              -- Specifies whether to include preview versions of the .NET SDK when
              -- determining which version to use for project loading.
              IncludePrereleases = true,
            },
          },
          -- enable_roslyn_analyzers = true,
          -- organize_imports_on_format = false,
          -- enable_import_completion = true,
          -- enable_editorconfig_support = true,
          -- enable_ms_build_load_projects_on_demand = false, -- When true, it's useful for big projects, but might not yield full autocompletion
        },
        -- you can do any additional lsp server setup here
        -- return true if you don't want this server to be setup with lspconfig
        ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
        setup = {
          -- omnisharp = function(_, opts)
          -- end
          -- example to setup with typescript.nvim
          -- tsserver = function(_, opts)
          --   require("typescript").setup({ server = opts })
          --   return true
          -- end,
          -- Specify * to use this function as a fallback for any server
          -- ["*"] = function(server, opts) end,
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
