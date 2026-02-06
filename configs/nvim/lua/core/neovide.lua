vim.o.guifont = "CaskaydiaMono NFM:i:h11"
-- Neovide may show a tiny strip at the bottom/right when the window size
-- isn't an exact multiple of the grid cell size (font metrics). Tweaking
-- `linespace` is an easy way to eliminate that.
vim.opt.linespace = -1
vim.keymap.set({ "n", "v" }, "<C-v>", [["+p]])
vim.keymap.set({ "i", "c" }, "<C-v>", "<C-r>+")
local mainColor = string.format("%x", vim.api.nvim_get_hl(0, { id = vim.api.nvim_get_hl_id_by_name("Normal") }).bg)
vim.g.neovide_hide_mouse_when_typing = false
vim.g.neovide_title_background_color = mainColor
vim.g.neovide_title_text_color = mainColor
vim.g.neovide_floating_blur_amount_x = 2.0
vim.g.neovide_floating_blur_amount_y = 2.0
vim.g.neovide_input_ime = true
--vim.g.neovide_fullscreen = true
vim.g.neovide_padding_top = 10
vim.g.neovide_padding_bottom = 0
vim.g.neovide_padding_right = 0
vim.g.neovide_padding_left = 0
local animation = true
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
