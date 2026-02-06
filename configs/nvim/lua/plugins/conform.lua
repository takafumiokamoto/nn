return {
    "stevearc/conform.nvim",
    config = function()
        require("conform").setup({
            formatters_by_ft = {
                lua = { "stylua" },
                go = { "gofmt" },
                python = { "ruff" },
                rust = { "rustfmt" },
                c = { "clang-format" },
                cpp = { "clang-format" },
                json = { "prettier" },
                jsonc = { "prettier" },
                yaml = { "prettier" },
                javascript = { "prettier" },
                javascriptreact = { "prettier" },
                typescript = { "prettier" },
                typescriptreact = { "prettier" },
                css = { "prettier" },
                scss = { "prettier" },
                html = { "prettier" },
                markdown = { "prettier" },
            },
            format_on_save = true,
        })
    end,
}
