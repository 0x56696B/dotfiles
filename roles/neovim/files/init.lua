local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  -- bootstrap lazy.nvim
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

require('lazy').setup {
  spec = {
    -- add LazyVim and import its plugins
    {
      'LazyVim/LazyVim',
      import = 'lazyvim.plugins',
    },

    -- import/override with
    { import = 'plugins.base' },
    { import = 'plugins.editor' },
    { import = 'plugins.lang' },
  },
  defaults = {
    lazy = true,
    version = false, -- always use the latest git commit
  },
  checker = { enabled = false, notify = false },
  debug = false,
  diff = {
    cmd = 'diffview.nvim',
  },
  performance = {
    cache = {
      enabled = true,
    },
    rtp = {
      disabled_plugins = {
        'gzip',
        'matchit',
        'matchparen',
        'netrwPlugin',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
      },
    },
    -- For debugging issues
    profiling = {
      -- Enables extra stats on the debug tab related to the loader cache.
      -- Additionally gathers stats about all package.loaders
      loader = false,
      -- Track each new require in the Lazy profiling tab
      require = false,
    },
  },
}
