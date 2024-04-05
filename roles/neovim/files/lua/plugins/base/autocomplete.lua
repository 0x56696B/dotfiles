return {
  {
    "hrsh7th/nvim-cmp",
    version = false,
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      -- "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "saadparwaiz1/cmp_luasnip" -- For snippets with LuaSnip
    },
    opts = function()
      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })

      local cmp = require("cmp")
      local compare = require("cmp").config.compare

      return {
        completion = {
          completeopt = "menu,menuone,noinsert",
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
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
        experimental = {
          ghost_text = {
            hl_group = "CmpGhostText",
          },
        },
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        sorting = {
          priority_weight = 1.0,
          comparators = {
            -- compare.score_offset, -- not good at all
            compare.locality,
            compare.recently_used,
            compare.score, -- based on :  score = score + ((#sources - (source_index - 1)) * sorting.priority_weight)
            compare.offset,
            compare.order,
            -- compare.scopes, -- what?
            -- compare.sort_text,
            -- compare.exact,
            -- compare.kind,
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

      cmp.event:on("confirm_done", function(event)
        if not vim.tbl_contains(opts.auto_brackets or {}, vim.bo.filetype) then
          return
        end
        local entry = event.entry
        local item = entry:get_completion_item()
        if vim.tbl_contains({ Kind.Function, Kind.Method }, item.kind) then
          local keys = vim.api.nvim_replace_termcodes("()<left>", false, false, true)
          vim.api.nvim_feedkeys(keys, "i", true)
        end
      end)

      -- For grouping the sources. KEEP AT THE BOTTOM!
      for _, source in ipairs(opts.sources) do
        source.group_index = source.group_index or 1
      end
    end,
  },

  -- Snippet engine
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "rafamadriz/friendly-snippets",
      {
        "hrsh7th/nvim-cmp",
        dependencies = {
          "saadparwaiz1/cmp_luasnip",
        },
      },
    },
    opts = {
      history = true,
      delete_check_events = "TextChanged",
    },
    keys = {
      {
        "<tab>",
        function()
          return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
        end,
        expr = true,
        silent = true,
        mode = "i",
      },
      { "<tab>",   function() require("luasnip").jump(1) end,  mode = "s" },
      { "<s-tab>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
    },
  },

  -- Snippet engine dependency
  {
    "rafamadriz/friendly-snippets",
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
}
