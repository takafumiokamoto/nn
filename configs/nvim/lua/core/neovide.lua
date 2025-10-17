vim.o.guifont = "CaskaydiaMono NFM:i:h11"
vim.keymap.set({ "n", "v" }, "<C-v>", [["+p]])
vim.keymap.set("i", "<C-v", "<C-r>+")
vim.g.neovide_input_ime = true
local animation = false
if animation then
    vim.g.neovide_cursor_animate_in_insert_mode = true
    vim.g.neovide_cursor_animate_command_line = true
    vim.g.neovide_cursor_smooth_blink = true
    vim.g.neovide_cursor_vfx_mode = "railgun"
else
    vim.g.neovide_position_animation_length = 0
    vim.g.neovide_cursor_animation_lenght = 0
    vim.g.neovide_cursor_trail_size = 0
    vim.g.neovide_cursor_animate_in_insert_mode = false
    vim.g.neovide_cursor_animate_command_line = false
    vim.g.neovide_cursor_animation_far_lines = 0
    vim.g.neovide_cursor_animation_length = 0
end
