vim.o.guifont = "CaskaydiaMono NFM:i:h10"
vim.keymap.set({ "n", "v" }, "<C-v>", [["+p]])
vim.keymap.set("i", "<C-v>", "<C-r>+")
local mainColor = string.format("%x", vim.api.nvim_get_hl(0, { id = vim.api.nvim_get_hl_id_by_name("Normal") }).bg)
vim.g.neovide_title_background_color = mainColor
vim.g.neovide_title_text_color = mainColor
vim.g.neovide_floating_blur_amount_x = 2.0
vim.g.neovide_floating_blur_amount_y = 2.0
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
