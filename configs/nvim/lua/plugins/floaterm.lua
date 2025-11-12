return {
    "nvzone/floaterm",
    enabled = false,
    dependencies = "nvzone/volt",
    cmd = "FloatermToggle",
    keys = {
        { "<C-\\>", "<cmd>FloatermToggle<cr>", mode = "n", desc = "Toggle Floaterm terminal" },
    },
    config = function()
        local floaterm = require("floaterm")
        floaterm.setup({

            border = false,
            size = { h = 60, w = 70 },

            -- to use, make this func(buf)
            mappings = { sidebar = nil, term = nil },

            -- Default sets of terminals you'd like to open
            terminals = {
                { name = "Terminal" },
                -- cmd can be function too
                { name = "Terminal", cmd = "neofetch" },
                -- More terminals
            },
        })
    end,
}
