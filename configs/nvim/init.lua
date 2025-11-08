require("core.lazy")
require("core.options")
require("core.keymaps")
require("core.lsp")
-- vim.cmd("colorscheme palenightfall")
vim.cmd("colorscheme vague")
--vim.g.material_style = "palenight"
--vim.cmd("colorscheme material")
if vim.g.neovide then
    require("core.neovide")
end
