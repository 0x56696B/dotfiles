return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    lazy = true,
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
      "3rd/image.nvim",
    },
    opts = {
      popup_border_style = "rounded",
      window = {
        position = "float",
        mappings = {
          ["<space>"] = "none",
          ["Y"] = {
            function(state)
              local node = state.tree:get_node()
              local path = node:get_id()
              vim.fn.setreg("+", path, "c")
            end,
            desc = "Copy path to Clipboard",
          },
        },
      },
      filesystem = {
        update_cwd = false,
        bind_to_cwd = false,
        cwd_target = {
          sidebar = "none",
          current = "none"
        },
        follow_current_file = { enabled = true },
        filtered_items = {
          visible = false,
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_hidden = true, -- OS: Windows only
          hide_by_name = {
            "node_modules"
          },
          hide_by_pattern = {
            "*.meta",
            --"*/src/*/tsconfig.json",
          },
          always_show = {
            ".gitignore",
          },
          never_show = {
            ".DS_Store",
            "thumbs.db",
            ".idea",
            ".vscode"
          },
          never_show_by_pattern = {
            --".null-ls_*",
          },
        },
        use_libuv_file_watcher = true,
      },
      indent = {
        indent_size = 4,
        padding = 2,
      },
      -- hijack_netrw_behavior = "open_current",
      sources = { "filesystem", "buffers", "git_status", "document_symbols" },
      open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
      default_component_configs = {
        indent = {
          with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander",
        },
      },
    }
  },

  -- Alternative file-tree
  -- NOTE: Disabled
  {
    "nvim-tree/nvim-tree.lua",
    lazy = true,
    enabled = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons"
    },
    init = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
    end,
    keys = {
      { "<leader>e", function() require("nvim-tree.api").tree.toggle() end, desc = "Open NvimTree" }
    },
    config = function()
      local config = {
        filters = {
          dotfiles = true,
        },
        actions = {
          change_dir = {
            enable = false
          }
        }
      }

      require("nvim-tree").setup(config)
    end
  }
}
