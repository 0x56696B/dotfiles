return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        background = {
          light = "latte",
          -- dark = "mocha",
          dark = "macchiato",
        },
        color_overrides = {
          latte ={
          },
          mocha = {
            rosewater = "#ea6962",
            flamingo = "#ea6962",
            red = "#ea6962",
            maroon = "#ea6962",
            pink = "#d3869b",
            mauve = "#d3869b",
            peach = "#e78a4e",
            yellow = "#d8a657",
            green = "#a9b665",
            teal = "#89b482",
            sky = "#89b482",
            sapphire = "#89b482",
            blue = "#7daea3",
            lavender = "#7daea3",
            text = "#ebdbb2",
            subtext1 = "#d5c4a1",
            subtext0 = "#bdae93",
            overlay2 = "#a89984",
            overlay1 = "#928374",
            overlay0 = "#595959",
            surface2 = "#4d4d4d",
            surface1 = "#404040",
            surface0 = "#292929",
            base = "#1d2021",
            mantle = "#191b1c",
            crust = "#141617",
          },
          macchiato = {
            rosewater = "#eb7a73",
            flamingo = "#eb7a73",
            red = "#eb7a73",
            maroon = "#eb7a73",
            pink = "#e396a4",
            mauve = "#e396a4",
            peach = "#e89a5e",
            yellow = "#e8b267",
            green = "#b9c675",
            teal = "#99c792",
            sky = "#99c792",
            sapphire = "#99c792",
            blue = "#8dbba3",
            lavender = "#8dbba3",
            text = "#f1e4c2",
            subtext1 = "#e5d5b1",
            subtext0 = "#c5bda3",
            overlay2 = "#b8a994",
            overlay1 = "#a39284",
            overlay0 = "#656565",
            surface2 = "#5d5d5d",
            surface1 = "#505050",
            surface0 = "#393939",
            base = "#2e3233",
            mantle = "#242727",
            crust = "#1f2223",
          },
        },
      })
    end,
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },

  {
    'cormacrelf/dark-notify',
    event = "VeryLazy",
    enabled = vim.fn.has('macunix'),
    priority = 999,
    opts = {
      schemes = {
        dark = "catppuccin-macchiato",
        light = "catppuccin-latte",
      },
    },
    config = function(_, opts)
      local dn = require('dark_notify');
      dn.run(opts)
    end,
  }
}
