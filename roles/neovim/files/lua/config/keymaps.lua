-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- <leader> and p or d deletes the selected text, rather then replacing the selected and copying it
vim.keymap.set({ "v" }, "p", '"_dP', { desc = "Paste w/o copy" })

-- Center when scrolling
vim.keymap.set({ "n", "x" }, "<C-u>", "<C-u>zz")
vim.keymap.set({ "n", "x" }, "<C-d>", "<C-d>zz")

-- Move lines
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Cursor remains in same position, when appending to upper line
vim.keymap.set("n", "J", "mzJ`z")

-- Search terms stay in the middle
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Saves changes when editing multi-line
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set({ "n", "v" }, "k", 'v:count == 0 ? "gk" : "k"', { expr = true, silent = true })
vim.keymap.set({ "n", "v" }, "j", 'v:count == 0 ? "gj" : "j"', { expr = true, silent = true })
