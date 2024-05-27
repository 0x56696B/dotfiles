return {
  { import = 'lazyvim.plugins.extras.coding.copilot' },

  -- Copilot
  {
    'zbirenbaum/copilot.lua',
    config = function(_, opts)
      if not vim.g.copilot then
        vim.cmd 'Copilot disable'
      end

      return opts
    end,
  },
}
