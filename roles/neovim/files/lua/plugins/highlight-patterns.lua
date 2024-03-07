return {
  -- Highlight patterns in text
  {
    "echasnovski/mini.hipatterns",
    event = "LazyFile",
    opts = function()
      local hi = require("mini.hipatterns")
      return {
        tailwind = {
          enabled = true,
          ft = { "typescriptreact", "javascriptreact", "css", "javascript", "typescript", "html" },
          -- full: the whole css class will be highlighted
          -- compact: only the color will be highlighted
          style = "compact",
        },
        highlighters = {
          hex_color = hi.gen_highlighter.hex_color({ priority = 2000 }),
        },
      }
    end,
    config = function(_, opts)
      require("mini.hipatterns").setup(opts)
    end,
  }
}
