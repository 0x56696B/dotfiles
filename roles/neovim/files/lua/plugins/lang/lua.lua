local function checkForLuaRocks()
  -- NOTE: luacheck requires `luarocks`
  return vim.fn.executable("luarocks") == 1
end

local mason = {
  "stylua", "lua-language-server"
}

return {
  -- Syntax Highlighting
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      if type(opts.ensure_installed) == 'table' then
        vim.list_extend(opts.ensure_installed, { "lua", "luadoc" })
      end
    end,
  },

  -- Install LSPs
  {
    'williamboman/mason.nvim',
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}

      if checkForLuaRocks() then
        vim.list_extend(mason, { "luacheck" })
      end

      vim.list_extend(opts.ensure_installed, mason)
    end,
  },

  -- LSP
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        lua_ls = {},
      }
    },
    config = {
      on_init = function(client)
        local path = client.workspace_folders[1].name
        if vim.loop.fs_stat(path .. '/.luarc.json') or vim.loop.fs_stat(path .. '/.luarc.jsonc') then
          return
        end

        client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
          runtime = {
            version = 'LuaJIT'
          },
          -- Make the server aware of Neovim runtime files
          workspace = {
            checkThirdParty = false,
            library = {
              vim.env.VIMRUNTIME
              -- Depending on the usage, you might want to add additional paths here.
              -- "${3rd}/luv/library"
              -- "${3rd}/busted/library",
            }
          }
        })
      end,
    }
  },

  -- Linter
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        ["lua"] = checkForLuaRocks() == true and { "luacheck" } or {},
      },
    },
  },
}
