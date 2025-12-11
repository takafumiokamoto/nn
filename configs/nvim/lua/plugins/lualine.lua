return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    enabled = false,
    config = function()
        local lualine = require("lualine")
        lualine.setup({
            options = {
                theme = "palenight",
                -- theme = "vague",
            },
        })
    end,
}
