local function fzf(command, opts)
    return function()
        require("fzf-lua")[command](opts or {})
    end
end

return {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "FzfLua",
    keys = {
        { "<leader>ff", fzf("files"), desc = "Find Files" },
        { "<leader>fg", fzf("live_grep"), desc = "Live Grep" },
        { "<leader>fb", fzf("buffers"), desc = "Find Buffers" },

        { "gd", fzf("lsp_definitions"), desc = "LSP Definitions" },
        { "gD", fzf("lsp_declarations"), desc = "LSP Declarations" },
        { "gy", fzf("lsp_typedefs"), desc = "LSP Type Definitions" },
        { "grr", fzf("lsp_references", { ignore_current_line = true }), desc = "LSP References" },
        { "gri", fzf("lsp_implementations"), desc = "LSP Implementations" },
        { "gO", fzf("lsp_document_symbols"), desc = "LSP Document Symbols" },
        {
            "gra",
            fzf("lsp_code_actions"),
            mode = { "n", "x" },
            desc = "LSP Code Actions",
        },
        { "<leader>lf", fzf("lsp_finder"), desc = "LSP Finder" },
        { "<leader>ls", fzf("lsp_live_workspace_symbols"), desc = "LSP Workspace Symbols" },
        { "<leader>ld", fzf("diagnostics_document"), desc = "Document Diagnostics" },
        { "<leader>lD", fzf("diagnostics_workspace"), desc = "Workspace Diagnostics" },
    },
}
