return {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = {
        { "mason-org/mason.nvim", opts = {} },
    },
    config = function()
        local tools = {
            "lua-language-server",
            "stylua",
        }
        if vim.fn.executable("go") == 1 then
            table.insert(tools, "gopls")
            table.insert(tools, "golangci-lint")
        end
        if vim.fn.executable("python") == 1 then
            table.insert(tools, "ruff")
            table.insert(tools, "pyright")
        end
        require("mason-tool-installer").setup({
            ensure_installed = tools,
            auto_update = true,
            run_on_start = true,
            start_delay = 5000,
            debounce_hours = 20,
        })
    end,
}
