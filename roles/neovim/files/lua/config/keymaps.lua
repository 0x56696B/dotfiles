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

-- Better indenting
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- TIP: Disable arrow keys in normal mode
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')
