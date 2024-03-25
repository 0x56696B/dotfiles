vim.keymap.set('n', '<leader>bo', '<cmd>%bd | e# <CR>', { desc = "Close all other buffers" })

return {
  -- WhickKey integration
  {
    "folke/which-key.nvim",
    opts = {
      defaults = {
        ["<leader>b"] = { name = "+buffer" },
      },
    },
  },
}
