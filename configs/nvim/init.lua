require("config.options")
require("config.keymaps")
require("config.lazy")
require("config.autocmd")
vim.lsp.enable("lua_ls")
vim.lsp.enable("gopls")
vim.lsp.enable("vtsls")
vim.cmd("colorscheme doom-one")
if vim.g.neovide then
    require("config.neovide")
end
