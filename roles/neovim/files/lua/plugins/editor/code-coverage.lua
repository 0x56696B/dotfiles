return {
  {
    'andythigpen/nvim-coverage',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    opts = {
      auto_reload = true,
    },
    keys = {
      {
        '<leader>cp',
        function()
          require('coverage').load()
          require('coverage').toggle()
        end,
        desc = 'Toggle Coverage',
        mode = 'n',
      },
      {
        '<leader>cP',
        function()
          require('coverage').load()
          require('coverage').summary()
        end,
        desc = 'Toggle Coverage',
        mode = 'n',
      },
    },
  },
}
