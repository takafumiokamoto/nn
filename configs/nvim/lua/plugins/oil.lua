return {
    "stevearc/oil.nvim",
    dependencies = {
        { "nvim-mini/mini.icons", opts = {} },
        { "nvim-tree/nvim-web-devicons", opts = {} },
    },
    lazy = false,
    config = function()
        require("oil").setup({
            columns = {
                "permissions",
                "size",
                "mtime",
                "icon",
            },
            skip_confirm_for_simple_edits = false,
            lsp_file_methods = {
                enabled = true,
                autosave_changes = true,
            },
            view_options = {
                show_hidden = true,
            },
            float = {
                padding = 2,
                max_width = 0.8,
                max_height = 0.8,
                border = nil,
                win_options = {
                    winblend = 1,
                },
            },
        })
        vim.keymap.set("n", "-", "<CMD>Oil --float<CR>", { desc = "Open parent directory" })
    end,
}
