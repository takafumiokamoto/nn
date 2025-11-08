-- clipboard
vim.keymap.set("v", "<C-c>", [["+y]], { desc = "Copy to Clipboard" })
vim.keymap.set("v", "<C-x>", [[+d]], { desc = "Cut to Clipboard" })
vim.keymap.set("n", "<C-a>", "ggVG", { desc = "Select All" })

-- multiline edit
vim.keymap.set("v", "<S-i>", "<C-v>^<S-i>", { desc = "Multiline edit from top of line" })
vim.keymap.set("v", "<S-i>", "<C-v>$<S-i>", { desc = "Multiline edit from end of line" })

-- navigation
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- lsp
vim.keymap.set("n", "gd", "<cmd>:lua vim.lsp.buf.definition()<CR>")

-- tab
vim.keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
vim.keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
vim.keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" })
vim.keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })
vim.keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })

--split
vim.keymap.set("n", "<leader>v", "<C-w>v", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>s", "<C-w>h", { desc = "Split window horizontally" })
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make scplits equal size" })
vim.keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

--buffer
vim.keymap.set("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Go to next buffer" })
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Go to previous buffer" })
vim.keymap.set("n", "<C-w>", "<cmd>bp|bd#<CR>", { desc = "Close" })

--miscellaneous
vim.keymap.set("i", "jk", "<ESC>", { desc = "" })
vim.keymap.set("i", "<C-h>", "<C-w>", { desc = "Delete word" })
vim.keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "clear search highlights" })
vim.keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" })
vim.keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" })
vim.keymap.set("v", "<", "<gv", { desc = "Outdent lines" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent lines" })
vim.keymap.set("v", "J", ":'<, '>m '>+1<CR>gv", { desc = "Move lines down" })
vim.keymap.set("v", "K", ":'<, '>m '>-2<CR>gv", { desc = "Move lines up" })
