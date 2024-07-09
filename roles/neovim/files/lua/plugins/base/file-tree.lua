return {
  {
    'nvim-neo-tree/neo-tree.nvim',
    lazy = true,
    branch = 'v3.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
      -- '3rd/image.nvim',
    },
    opts = {
      popup_border_style = 'rounded',
      indent = {
        indent_size = 4,
        padding = 2,
      },
      window = {
        position = 'float',
      },
      filesystem = {
        hide_by_pattern = {
          '*.meta',
          --"*/src/*/tsconfig.json",
        },
        always_show = {
          '.gitignore',
        },
        never_show = {
          '.DS_Store',
          'thumbs.db',
          '.idea',
          '.vscode',
        },
      },
    },
  },
}
