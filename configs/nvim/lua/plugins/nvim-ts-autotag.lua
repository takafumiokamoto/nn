return {
    "windwp/nvim-ts-autotag",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
        require("nvim-ts-autotag").setup({
            opts = {
                enable_close = true, -- Auto close tags
                enable_rename = true, -- Auto rename pairs of tags
                enable_close_on_slash = false, -- Auto close on trailing </
            },
            -- Enable for specific filetypes
            per_filetype = {
                ["html"] = { enable_close = true },
                ["jsx"] = { enable_close = true },
                ["tsx"] = { enable_close = true },
            },
        })
    end,
}
