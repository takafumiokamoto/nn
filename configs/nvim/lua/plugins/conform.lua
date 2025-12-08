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
                yaml = { "prettier" },
            },
            format_on_save = true,
        })
    end,
}
