local function hasTailwindConfig()
  return vim.fn.glob("./tailwind.config.js", false, true) ~= "" or
      vim.fn.glob("./tailwind.config.ts", false, true) ~= ""
end

return {
  -- Highlight patterns in text
  {
    "echasnovski/mini.hipatterns",
    event = "LazyFile",
    opts = function()
      local config = {}
      local hi = require("mini.hipatterns")

      if hasTailwindConfig() then
        local tailwind = {
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
        };

        vim.list_extend(config, tailwind)
      end

      return config
    end,
    config = function(_, opts)
      require("mini.hipatterns").setup(opts)
    end,
  }
}
