-- NOTE: Disabled
-- if true then
--   return {}
-- end

local markdown_files = {
  'markdown', 'norg', 'rmd', 'org'
}

return {
  -- Hightlighting support
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      if type(opts.ensure_installed) == 'table' then
        vim.list_extend(opts.ensure_installed, { 'markdown', 'markdown_inline' })
      end
    end,
  },

  -- LSP
  {
    'williamboman/mason.nvim',
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { 'markdownlint', 'marksman' })
    end,
  },

  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        marksman = {},
      },
    },
  },

  -- Formatter
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        markdown = { 'markdownlint' },
      },
      formatters = {
        markdownlint = {},
      },
    },
  },

  -- Linter
  {
    'mfussenegger/nvim-lint',
    opts = {
      linters_by_ft = {
        markdown = { 'markdownlint' },
      },
    },
  },

  -- Nicer Markdown look
  {
    'lukas-reineke/headlines.nvim',
    event = "VeryLazy",
    opts = function()
      local opts = {}
      for _, ft in ipairs(markdown_files) do
        opts[ft] = {
          headline_highlights = {},
        }
        for i = 1, 6 do
          local hl = 'Headline' .. i
          vim.api.nvim_set_hl(0, hl, { link = 'Headline', default = true })
          table.insert(opts[ft].headline_highlights, hl)
        end
      end
      return opts
    end,
    ft = markdown_files,
    config = function(_, opts)
      -- PERF: schedule to prevent headlines slowing down opening a file
      vim.schedule(function()
        require('headlines').setup(opts)
        require('headlines').refresh()
      end)
    end,
  },

  -- Tables
  {
    'dhruvasagar/vim-table-mode',
    event = { "VeryLazy" },
    ft = markdown_files,
    keys = {
      { "<leader>ct", "<cmd>TableModeToggle<cr>", desc = "Toggle Table Mode" }
    }
  }
}
