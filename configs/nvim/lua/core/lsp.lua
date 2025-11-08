for _, path in ipairs(vim.api.nvim_get_runtime_file("lsp/*.lua", true)) do
    local name = vim.fs.basename(path):gsub("%.lua$", "")
    local cfg = dofile(path)
    vim.lsp.config(name, cfg)
    vim.lsp.enable(name)
end
