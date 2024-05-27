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
      'lewis6991/gitsigns.nvim', -- For changed lines formatting
    },
    opts = {
      format = {
        async = true,
        lsp_fallback = true,
        timeout_ms = 3000,
      },
      formatters_by_ft = {
        lua = { 'stylua' },
        sh = { 'shfmt' },
      },
      formatters = {
        injected = {
          options = {
            ignore_errors = true,
          },
        },
      },
    },
    init = function()
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
    keys = {
      {
        '<leader>cf',
        function()
          require('conform').format()
        end,
        mode = { 'n' },
        desc = 'Format',
      },
      {
        '<leader>cF',
        function()
          local ignore_filetypes = { 'lua' }
          if vim.tbl_contains(ignore_filetypes, vim.bo.filetype) then
            vim.notify('Range formatting for file ' .. vim.bo.filetype .. ' disabled')
            return
          end

          local hunks = require('gitsigns').get_hunks()
          if hunks == nil then
            return
          end

          local function format_range()
            if next(hunks) == nil then
              vim.notify('Done formatting', 'info', { title = 'formatting' })
              return
            end
            local hunk = nil
            while next(hunks) ~= nil and (hunk == nil or hunk.type == 'delete') do
              hunk = table.remove(hunks)
            end

            if hunk ~= nil and hunk.type ~= 'delete' then
              local start = hunk.added.start
              local last = start + hunk.added.count

              local msg = 'Hunk formatting. Start: ' .. start .. '; End: ' .. last .. ';'
              vim.notify(msg, { title = 'notify'})
              -- nvim_buf_get_lines uses zero-based indexing -> subtract from last
              local last_hunk_line = vim.api.nvim_buf_get_lines(0, last - 2, last - 1, true)[1]
              local range = { start = { start, 0 }, ['end'] = { last - 1, last_hunk_line:len() } }
              -- require('conform').format({ range = range, async = true, lsp_fallback = true }, function()
              --   vim.defer_fn(function()
              --     format_range()
              --   end, 1)
              -- end)

              require('conform').format({ range = range, async = true, lsp_fallback = true })
            end
          end

          format_range()
        end,
        mode = { 'n' },
        desc = 'Format changed only',
      },
    },
  },

  {
    'williamboman/mason.nvim',
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { 'stylua', 'shfmt' })
    end,
  },
}
