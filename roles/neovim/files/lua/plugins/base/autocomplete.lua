vim.g.lazyvim_blink_main = false

return {
  { import = 'lazyvim.plugins.extras.coding.blink' },

  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        documentation = {
          auto_show_delay_ms = 20,
        },
      },
      keymap = {
        preset = "default",
        ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
      },
    }
  }
}
