return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = {
    {
      "windwp/nvim-ts-autotag",
      opts = function(_, opts)
        ---@diagnostic disable-next-line: missing-fields
        require("nvim-treesitter.configs").setup({
          autotag = {
            enable = true,
            enable_rename = true,
            enable_close = true,
            enable_close_on_slash = true,
            -- filetypes = { "html", "xml" },
          },
          highlight = {
            additional_vim_regex_highlighting = false,
          },
        })
      end,
    },
  },
}
