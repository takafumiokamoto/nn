require("config.options")
require("config.keymaps")
require("config.lazy")
require("config.autocmd")
for _, path in ipairs(vim.fn.glob(vim.fn.stdpath("config") .. "/lsp/*.lua", false, true)) do
    vim.lsp.enable(vim.fn.fnamemodify(path, ":t:r"))
end
vim.cmd("colorscheme doom-one")
if vim.g.neovide then
    require("config.neovide")
end
