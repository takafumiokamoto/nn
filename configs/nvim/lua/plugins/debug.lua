return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio",
        "leoluz/nvim-dap-go",
    },
    config = function()
        require("dap-go").setup({
            delve = {
                detached = vim.fn.has("win32") == 0,
            },
        })
    end,
}
