-- vim.api.nvim_set_hl(0, "OilGitIgnored", { link = "Comment" })

return {
  { "nvim-neo-tree/neo-tree.nvim", enabled = false },

  {
    "stevearc/oil.nvim",
    lazy = false,
    dependencies = {
      { "echasnovski/mini.icons", opts = {} },
      { "nvim-tree/nvim-web-devicons" }
    },
    keys = {
      {
        "<leader>E",
        function()
          if vim.bo.filetype == "oil" then
            require("oil").close()
          else
          require("oil").open(LazyVim.root())
          end
        end,

        desc = "Open Root directory",
        mode = "n"
      },
      {
        "<leader>e",
        function()
          if vim.bo.filetype == "oil" then
            require("oil").close()
          else
            require('oil').open()
          end
        end,
        desc = "Toggle Oil in Parent directory",
        mode = "n",
      },

    },
    ---@module "oil"
    ---@type oil.SetupOpts
    opts = {
      delete_to_trash = true,
      watch_for_changes = true,
      view_options = {
        show_hidden = true,
        -- This function defines what is considered a "hidden" file
        is_hidden_file = function(name, bufnr)
          local hidden = name:match("^%.") ~= nil
          local env = name:match("^%.env(%..+)?$") ~= nil

          return hidden and not env
        end,
        -- This function defines what will never be shown, even when `show_hidden` is set
        is_always_hidden = function(name, bufnr)
          local git = name:match("^%.git") ~= nil

          return git
        end,
        natural_order = "fast",
        case_insensitive = false,
        sort = {
          { "type", "asc" },
          { "name", "asc" },
        },
        -- Customize the highlight group for the file name
        -- FIXME: TOO SLOW, FIND BETTER APPROACH
        -- highlight_filename = function(entry, is_hidden, is_link_target, is_link_orphan)
        --   local output = vim.fn.system("git check-ignore " .. vim.fn.shellescape(entry.path))
        --
        --   if output ~= "" then
        --     -- The name of the custom Oil git ignored highlight group
        --     return "OilGitIgnored"
        --   end
        --
        --   return nil
        -- end,
      },
      git = {
        add = function(path)
          return true
        end,
        mv = function(src_path, dest_path)
          return true
        end,
        rm = function(path)
          return true
        end,
      },
    },
  }
}
