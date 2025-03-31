-- NOTE: Workaround so mermaid files can be rendered like Markdown
vim.filetype.add {
  extension = {
    mmd = "markdown",
    mermaid = "markdown",
  },
}

return {
  { import = "lazyvim.plugins.extras.lang.markdown" },

  {
    "iamcco/markdown-preview.nvim",
    keys = {
      { "<leader>cp", false },

      {
        "<leader>mp",
        ft = { "markdown", "mermaid" },
        "<cmd>MarkdownPreviewToggle<cr>",
        desc = "Markdown Preview",
      },
    },
  },
}
