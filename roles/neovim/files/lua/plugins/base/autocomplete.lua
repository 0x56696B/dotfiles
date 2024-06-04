local keyword_len = 1;

return {
  {
    'hrsh7th/nvim-cmp',
    opts = function(_, opts)
      local cmp = require 'cmp'
      -- local compare = require('cmp').config.compare

      local config = {
        region_check_events = 'CursorHold,InsertLeave',
        delete_check_events = 'TextChanged,InsertEnter',
        completion = {
          keyword_length = keyword_len,
        },
        mapping = cmp.mapping.preset.insert {
          ['<C-y>'] = cmp.mapping.confirm { select = true },
          ["<CR>"] = nil,
        },
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'path' },
        }, {
          { name = 'buffer' },
        }, {
          name = 'nvim_lsp_signature_help',
        }),
        -- sorting = {
        --   priority_weight = 1.0,
        --   comparators = {
        --     compare.offset,
        --     compare.exact,
        --     compare.score, -- based on :  score = score + ((#sources - (source_index - 1)) * sorting.priority_weight)
        --     compare.recently_used,
        --     compare.locality,
        --     compare.kind,
        --     compare.order,
        --     compare.scopes, -- what?
        --     -- compare.score_offset, -- not good at all
        --     -- compare.sort_text,
        --     -- compare.length, -- useless
        --   },
        -- },
      }

      return vim.tbl_deep_extend('force', opts, config)
    end,
    config = function(_, opts)
      table.insert(opts.sources, { name = 'luasnip' })

      local cmp = require 'cmp'
      cmp.setup(opts)

      for _, source in ipairs(opts.sources) do
        source.keyword_length = opts.completion.keyword_length or keyword_len;
      end
    end,
  },
}
