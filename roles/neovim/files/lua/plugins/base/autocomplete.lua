return {
  {
    'hrsh7th/nvim-cmp',
    opts = function(_, opts)
      local cmp = require 'cmp'

      local config = {
        region_check_events = 'CursorHold,InsertLeave',
        delete_check_events = 'TextChanged,InsertEnter',
        mapping = cmp.mapping.preset.insert {
          ['<C-y>'] = cmp.mapping.confirm { select = true },
          ['<CR>'] = nil,
        },
      }

      return vim.tbl_deep_extend('force', opts, config)
    end,
  },
}
