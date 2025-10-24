require("core.lazy")
require("core.options")
require("core.keymaps")
require("core.lsp")
vim.cmd("colorscheme palenightfall")
--vim.cmd("colorscheme vague")
if vim.g.neovide then
    require("core.neovide")
end
