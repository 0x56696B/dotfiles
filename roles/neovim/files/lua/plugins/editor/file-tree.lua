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
        position = "float"
      },
      filesystem = {
        update_cwd = false,
        bind_to_cwd = true,
        follow_current_file = { enabled = true },
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
        }
      },
      indent = {
        indent_size = 4,
        padding = 2,
      },
      -- hijack_netrw_behavior = "open_current",
      use_libuv_file_watcher = true
    }
  },

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
