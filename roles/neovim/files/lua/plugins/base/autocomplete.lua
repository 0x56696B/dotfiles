if vim.g.enable_blink then
  return {
    {
      "saghen/blink.cmp",
      opts = {
        appearance = {
          use_nvim_cmp_as_default = false, -- Let it stay until blink works as expected
        },
        completion = {
          documentation = {
            auto_show_delay_ms = 20,
          },
        },
        sources = {
          providers = {
            lsp = {
              min_keyword_length = 0,
              async = true,
            },
          }
        },
        -- experimental signature help support
        signature = { enabled = true },
        keymap = {
          preset = "default",
        },
      }
    }
  }
else
  return {
    { import = 'lazyvim.plugins.extras.coding.nvim-cmp' },

    {
      'hrsh7th/nvim-cmp',
      enabled = true,
      opts = function(_, opts)
        local cmp = require 'cmp'

        local config = {
          region_check_events = 'CursorHold,InsertLeave',
          delete_check_events = 'TextChanged,InsertEnter',
          completion = {
            keyword_length = 1,
            max_item_count = 7,
          },
          mapping = cmp.mapping.preset.insert {
            ['<C-y>'] = cmp.mapping.confirm { select = true },
            ["<C-Space>"] = cmp.mapping.complete(),
            ['<CR>'] = nil,
          },
        }

        return vim.tbl_deep_extend('force', opts, config)
      end,
    },
  }
end
