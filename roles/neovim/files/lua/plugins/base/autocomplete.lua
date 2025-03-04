vim.g.lazyvim_blink_main = false

return {
  { import = 'lazyvim.plugins.extras.coding.blink' },

  {

    "saghen/blink.cmp",
    enabled = vim.g.enable_blink or false,
    opts = {
      completion = {
        documentation = {
          auto_show_delay_ms = 20,
        },
      },
      keymap = {
        preset = "default",
      },
    }
  }
}
