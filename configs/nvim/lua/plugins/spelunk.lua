return {
    {
        "EvWilson/spelunk.nvim",
        dependencies = {
            "ibhagwan/fzf-lua",
        },
        config = function()
            require("spelunk").setup({
                enable_persist = true,
                enable_status_col_display = true,
                fuzzy_search_provider = "fzf-lua",
            })
        end,
    },
}
