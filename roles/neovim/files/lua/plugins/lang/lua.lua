local treesitter = { "lua", "luadoc" }
local mason = {
  -- LSPs
  "lua-language-server",

  -- Linter
  "luacheck",

  -- Format
  "stylua",
}

return {
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
        lua_ls = {
          settings = {
            telemetry = {
              enable = false,
            },
            format = {
              enable = false,
              defaultConfig = {
                indent_style = "space",
                indent_size = "2",
                continuation_indent_size = "2",
              },
            },
            diagnostics = {
              globals = { "vim", "hs" },
            },
            workspace = {
              library = {
                [vim.fn.expand "$VIMRUNTIME/lua"] = true,
                [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
                ["/Applications/Hammerspoon.app/Contents/Resources/extensions/hs/"] = true,
                [vim.fn.expand "$HOME/.hammerspoon/Spoons/EmmyLua.spoon/annotations"] = true
              },
            },
          },
        },
      },
    },
  },
}
