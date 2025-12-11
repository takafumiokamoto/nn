require("core.lazy")
require("core.options")
require("core.keymaps")
require("core.autocmds")
require("core.lsp")
vim.cmd("colorscheme palenightfall")
if vim.g.neovide then
    require("core.neovide")
end
