return {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter.configs").setup({
            ensure_installed = {
                "lua",
                "go",
                "python",
                "c",
                "cpp",
                "yaml",
                "json",
            },
            sync_install = true,
            auto_install = true,
            highlight = {
                enable = true,
            },
        })
    end,
}
