-- NOTE: Disabled
-- Testing new autocomplete plugins
if true then
  return {}
end

return {
  {

    'hrsh7th/nvim-cmp',
    enabled = false,
  },

  {
    -- Python virtual env and universal ctags are needed as dependencies
    -- `sudo apt install -y python3.11-venv universal-ctags`
    'ms-jpq/coq_nvim',
    dependencies = {
      'neovim/nvim-lspconfig',
    },
    branch = "coq",
    lazy = false,
    build = ":COQdeps",
    init = function()
      vim.g.coq_settings = {
        auto_start = 'shut-up',
        xdg = true
      }
    end,
  },
}
