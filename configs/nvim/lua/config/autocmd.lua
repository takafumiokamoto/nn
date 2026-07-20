vim.filetype.add({
    extension = {
        ["sublime-keymap"] = "jsonc",
        ["sublime-settings"] = "jsonc",
    },
})

vim.api.nvim_create_autocmd("ColorSchemePre", {
    pattern = "accent",
    callback = function()
        vim.g.accent_color = "magenta"
    end,
})
