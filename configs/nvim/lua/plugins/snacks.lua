local unpack = unpack or table.unpack

local function snacks(command, ...)
    local args = { n = select("#", ...), ... }

    return function()
        require("snacks")[command](unpack(args, 1, args.n))
    end
end

return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
        bigfile = { enabled = false },
        bufdelete = { enabled = true },
        dashboard = { enabled = false },
        explorer = { enabled = false },
        image = { enabled = false },
        indent = { enabled = false },
        input = { enabled = false },
        notifier = { enabled = false },
        picker = { enabled = false },
        quickfile = { enabled = false },
        scope = { enabled = false },
        scroll = { enabled = false },
        statuscolumn = { enabled = false },
        words = { enabled = false },
    },
    keys = {
        { "<leader>bd", snacks("bufdelete"), desc = "Delete Buffer" },
        {
            "<c-\\>",
            snacks("terminal", nil, {
                win = { position = "float", border = "rounded" },
            }),
            desc = "Toggle Terminal",
            mode = { "n", "t" },
        },
    },
}
