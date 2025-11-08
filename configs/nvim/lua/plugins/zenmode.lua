return {
    "folke/zen-mode.nvim",
    opts = {},
    config = function()
        vim.keymap.set("n", "<leader>z", "<CMD>ZenMode<CR>", { desc = "Toggle ZenMode" })
    end,
}
