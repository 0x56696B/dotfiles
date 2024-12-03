vim.g.copilot = true

return {
  { import = 'lazyvim.plugins.extras.ai.copilot' },

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
