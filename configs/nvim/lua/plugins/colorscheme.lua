return {
    {
        "JoosepAlviste/palenightfall.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            local palenight = require("palenightfall")
            palenight.setup({
                transparent = true,
                italic = true,
            })
        end,
    },
}
