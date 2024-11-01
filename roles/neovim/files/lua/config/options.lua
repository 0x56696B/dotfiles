-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.loader.enable()

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.did_load_filetype = 1
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0
vim.g.autoformat = false

vim.bo.softtabstop = 2
vim.opt.hlsearch = false
vim.opt.breakindent = true
vim.opt.shell = 'zsh'
vim.opt.autochdir = false

-- Delete buffer when closed
vim.bo.bufhidden = 'delete'

-- Root detection config
-- Fixes mono repo errors
vim.g.root_spec = { { ".git", "lua" }, "lsp", "cwd" }

-- Prevent multiple tabpages
vim.o.tabpagemax = 0
vim.o.showtabline = 0

-- Personal custom options
