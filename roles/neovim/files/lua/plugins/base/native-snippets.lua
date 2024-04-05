if not vim.snippet then
  return {}
end

return {
  {
    "L3MON4D3/LuaSnip",
    enabled = false,
  },

  {
    "hrsh7th/nvim-cmp",
    opts = {
      snippet = {
        expand = function(args)
          vim.snippet.expand(args.body)
        end,
      },
    },
    keys = {
      {
        "<Tab>",
        function()
          if vim.snippet.jumpable(1) then
            vim.schedule(function()
              vim.snippet.jump(1)
            end)
            return
          end
          return "<Tab>"
        end,
        expr = true,
        silent = true,
        mode = "i",
      },
      {
        "<Tab>",
        function()
          vim.schedule(function()
            vim.snippet.jump(1)
          end)
        end,
        silent = true,
        mode = "s",
      },
      {
        "<S-Tab>",
        function()
          if vim.snippet.jumpable(-1) then
            vim.schedule(function()
              vim.snippet.jump(-1)
            end)
            return
          end
          return "<S-Tab>"
        end,
        expr = true,
        silent = true,
        mode = { "i", "s" },
      },
    },
  },
}
