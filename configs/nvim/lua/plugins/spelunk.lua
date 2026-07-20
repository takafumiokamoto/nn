return {
    {
        "EvWilson/spelunk.nvim",
        dependencies = {
            "ibhagwan/fzf-lua",
        },
        config = function()
            require("spelunk").setup({
                base_mappings = {
                    toggle = "<leader>mm",
                    add = "<leader>ma",
                    delete = "<leader>md",
                    next_bookmark = "<leader>.",
                    prev_bookmark = "<leader>,",
                    search_bookmarks = "<leader>mf",
                    search_current_bookmarks = "<leader>mc",
                    search_stacks = "<leader>ms",
                    change_line = "<leader>ml",
                },
                window_mappings = {
                    bookmark_down = "J",
                    bookmark_up = "K",
                },
                enable_persist = true,
                enable_status_col_display = true,
                fuzzy_search_provider = "fzf-lua",
            })
        end,
    },
}
