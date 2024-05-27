return {
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp = require("cmp")
      local compare = require("cmp").config.compare

      local config = {
        region_check_events = "CursorHold,InsertLeave",
        delete_check_events = "TextChanged,InsertEnter",
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-y>"] = cmp.mapping.confirm({ select = true }),
          ["<S-CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }),
          ["<C-CR>"] = function(fallback)
            cmp.abort()
            fallback()
          end,
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "path" },
        }, {
          { name = "buffer" },
        }, {
          name = "nvim_lsp_signature_help"
        }),
        sorting = {
          priority_weight = 1.0,
          comparators = {
            compare.offset,
            compare.exact,
            compare.score, -- based on :  score = score + ((#sources - (source_index - 1)) * sorting.priority_weight)
            compare.recently_used,
            compare.locality,
            compare.kind,
            compare.order,
            compare.scopes, -- what?
            -- compare.score_offset, -- not good at all
            -- compare.sort_text,
            -- compare.length, -- useless
          },
        }
      }

      return vim.tbl_deep_extend("force", opts, config)
    end,
    config = function(_, opts)
      table.insert(opts.sources, { name = "luasnip" })

      local cmp = require("cmp")
      cmp.setup(opts)

      -- For autocomplete in command line mode
      cmp.setup.cmdline(":", {
        sources = cmp.config.sources({
          { name = "path" },
          { name = "cmdline" },
        })
      })
    end,
  },
}
