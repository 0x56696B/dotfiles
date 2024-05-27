local treesitter = { 'git_config', 'git_rebase', 'gitcommit', 'gitignore' }

return {
  -- Syntax highlighting
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      if type(opts.ensure_installed) == 'table' then
        vim.list_extend(opts.ensure_installed, treesitter)
      end
    end,
  },
}
