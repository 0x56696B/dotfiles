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
      follow_current_file = {
        enabled = true,
        leave_dirs_open = true,
      },
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
        always_show_by_pattern = {
          "./**/.env",
          "./**/.env*",
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
