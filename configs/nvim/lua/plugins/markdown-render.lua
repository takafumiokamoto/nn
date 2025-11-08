return {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ft = { "markdown" },
    config = function()
        require("render-markdown").setup({})
        vim.keymap.set("n", "<leader>md", "<CMD>RenderMarkdown toggle<CR>")
    end,
}
