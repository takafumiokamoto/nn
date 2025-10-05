-- clipboard
vim.keymap.set("v", "<C-c>", [["+y]], { desc = "Copy to Clipboard" })
vim.keymap.set("v", "<C-x>", [["+d]], { desc = "Cut to Clipboard" })
vim.keymap.set("n", "<C-a>", "ggVG", { desc = "Select All" })

-- multiline edit
vim.keymap.set("v", "I", "<C-v>^I", { desc = "Multiline edit from start of line" })
vim.keymap.set("v", "A", "<C-v>$A", { desc = "Multiline edit from end of line" })

-- navigation
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- tab
vim.keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
vim.keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
vim.keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" })
vim.keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })
vim.keymap.set("n", "<leader>tf", "<cmd>tabsplit<CR>", { desc = "Open current buffer in new tab" })

--split
vim.keymap.set("n", "<leader>v", "<C-w>v", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>h", "<C-w>s", { desc = "Split window horizontally" })
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
vim.keymap.set("n", "<Right>", "<C-w><")
vim.keymap.set("n", "<Left>", "<C-w>>")
vim.keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

--buffer
vim.keymap.set("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Go to next buffer" })
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Go to previous buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>bp|bd#<CR>", { desc = "Close buffer" })

--miscellaneous
vim.keymap.set("i", "jk", "<ESC>", { desc = "" })
vim.keymap.set("i", "<C-h>", "<C-w>", { desc = "Delete word" })
vim.keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "clear search highlights" })
vim.keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" })
vim.keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" })
vim.keymap.set("v", "<", "<gv", { desc = "Outdent lines" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent lines" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move lines down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move lines up" })

vim.keymap.set("n", "<leader>us", function()
    vim.o.laststatus = vim.o.laststatus == 0 and 3 or 0
end, { desc = "Toggle status line" })

-- diagnostics
vim.keymap.set("n", "<leader>le", vim.diagnostic.open_float, { desc = "Show Line Diagnostics" })
vim.keymap.set("n", "<leader>lq", vim.diagnostic.setloclist, { desc = "Diagnostic Location List" })
