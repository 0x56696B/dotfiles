-- vim.api.nvim_create_user_command("DiffFormat", function()
--   local current_file_name = vim.api.nvim_buf_get_name(0)
--   local lines = vim.fn.system("git diff --unified=0 --no-color -- " .. current_file_name):gmatch("[^\n\r]+")
--   local ranges = {}
--
--   for line in lines do
--     if line:find("^@@") then
--       local line_nums = line:match("%+.- ")
--       if line_nums:find(",") then
--         local _, _, first, second = line_nums:find("(%d+),(%d+)")
--         table.insert(ranges, {
--           start = { tonumber(first), 0 },
--           ["end"] = { tonumber(first) + tonumber(second), 0 },
--         })
--       else
--         local first = tonumber(line_nums:match("%d+"))
--         table.insert(ranges, {
--           start = { first, 0 },
--           ["end"] = { first + 1, 0 },
--         })
--       end
--     end
--   end
--
--   local conform = require("conform")
--   for _, range in pairs(ranges) do
--     conform.format({
--       range = range,
--     })
--   end
-- end, { desc = "Format changed lines" })

return {
  {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    dependencies = {
      'williamboman/mason.nvim',
    },
    opts = {
      format = {
        async = true,
        lsp_fallback = true,
        timeout_ms = 3000,
      },
      formatters_by_ft = {
        lua = { "stylua" },
        sh = { "shfmt" },
      },
      formatters = {
        injected = {
          options = {
            ignore_errors = true
          }
        },
      },
    },
    init = function()
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
    keys = {
      {
        '<leader>cF',
        function()
          local start_pos = vim.fn.getpos 'v'
          local end_pos = vim.fn.getpos '.'

          local range = {
            start = { start_pos[1], 0 },
            ['end'] = { end_pos[1] + 1, 0 },
          }

          require('conform').format { async = true, lsp_fallback = true, range = range }
        end,
        mode = { 'x', 'v' },
        desc = 'Format in selection',
      },
    },
  },

  {
    'williamboman/mason.nvim',
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "stylua", "shfmt" })
    end,
  },
}
