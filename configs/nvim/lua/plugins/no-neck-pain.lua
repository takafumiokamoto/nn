return {
    "shortcuts/no-neck-pain.nvim",
    version = "*",
    config = function()
        vim.keymap.set("n", "<leader>n", function()
            vim.cmd("NoNeckPain")
        end)
    end,
}
