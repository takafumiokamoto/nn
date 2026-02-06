local disabled_servers = {
    eslint = true,
}

for _, path in ipairs(vim.api.nvim_get_runtime_file("lsp/*.lua", true)) do
    local name = vim.fs.basename(path):gsub("%.lua$", "")
    if not disabled_servers[name] then
        local cfg = dofile(path)
        vim.lsp.config(name, cfg)
        vim.lsp.enable(name)
    end
end
vim.diagnostic.config({
    virtual_lines = true,
})
-- keymaps
vim.keymap.set("n", "gd", "<cmd>:lua vim.lsp.buf.definition()<CR>")
vim.keymap.set({ "n", "v" }, "gra", "<cmd>:lua vim.lsp.buf.code_action()<cr>")
vim.keymap.set({ "n", "v" }, "gri", "<cmd>:lua vim.lsp.buf.implementation()<cr>")
vim.keymap.set({ "n", "v" }, "grn", "<cmd>:lua vim.lsp.buf.rename()<cr>")
vim.keymap.set({ "n", "v" }, "grr", "<cmd>:lua vim.lsp.buf.references()<cr>")
vim.keymap.set({ "n", "v" }, "grt", "<cmd>:lua vim.lsp.buf.type_definition()<cr>")
vim.keymap.set({ "n", "v" }, "gO", "<cmd>:lua vim.lsp.buf.document_symbol()<cr>")
vim.keymap.set("i", "<C-s>", "<cmd>:lua vim.lsp.buf.signature_help()<cr>")
