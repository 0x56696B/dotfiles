return {
  {
    "hrsh7th/nvim-cmp",
    opts = function()
      local cmp = require("cmp")
      local compare = require("cmp").config.compare

      return {
        completion = {
          completeopt = "menu,menuone,noinsert",
        },
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
        formatting = {},
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

  -- Snippet engine
  -- {
  --   "L3MON4D3/LuaSnip",
  --   dependencies = {
  --     "rafamadriz/friendly-snippets",
  --     {
  --       "hrsh7th/nvim-cmp",
  --       dependencies = {
  --         "saadparwaiz1/cmp_luasnip",
  --       },
  --     },
  --   },
  --   opts = {
  --     history = true,
  --     delete_check_events = "TextChanged",
  --   },
  --   keys = {
  --     {
  --       "<tab>",
  --       function()
  --         return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
  --       end,
  --       expr = true,
  --       silent = true,
  --       mode = "i",
  --     },
  --     { "<tab>",   function() require("luasnip").jump(1) end,  mode = "s" },
  --     { "<s-tab>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
  --   },
  -- },
  --
  -- -- Snippet engine dependency
  -- {
  --   "rafamadriz/friendly-snippets",
  --   config = function()
  --     require("luasnip.loaders.from_vscode").lazy_load()
  --   end,
  -- },
}
