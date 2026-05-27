-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

vim.api.nvim_create_user_command('Bd', function(args)
  vim.cmd(args.bang and 'bp | bd! #' or 'bp | bd #')
end, { bang = true })
