local wezterm = require("wezterm")
local mux = wezterm.mux
local config = wezterm.config_builder()

config.font_size = 11
config.font = wezterm.font("CaskaydiaMono NFM", { italic = true })
-- config.font = wezterm.font('Victor Mono SemiBold', { italic = true })
config.color_scheme = "Palenight (Gogh)"
config.hide_tab_bar_if_only_one_tab = true
config.audible_bell = "Disabled"
config.use_ime = true
-- config.default_domain = 'WSL:Debian'
config.default_domain = "WSL:Ubuntu-24.04"
--config.default_prog = { "pwsh.exe" }
config.window_background_opacity = 1
config.win32_system_backdrop = "Acrylic"
config.win32_system_backdrop = "Tabbed"
config.win32_system_backdrop = "Mica"
config.window_decorations = "RESIZE"
config.window_decorations = "RESIZE"
--config.window_decorations = "RESIZE | TITLE"
-- maximize window on startup
wezterm.on("gui-startup", function(window)
    local tab, pane, window = mux.spawn_window(cmd or {})
    local gui_window = window:gui_window()
    gui_window:maximize()
end)
config.window_padding = {
    left = 2,
    right = 2,
    top = 5,
    bottom = 0,
}

local action = wezterm.action
config.keys = {
    { key = "Enter", mods = "SHIFT", action = wezterm.action({ SendString = "\x1b\r" }) },
    {
        key = "w",
        mods = "SHIFT|CTRL",
        action = wezterm.action({ CloseCurrentTab = { confirm = false } }),
    },
    { key = "v", mods = "CTRL", action = wezterm.action({ PasteFrom = "Clipboard" }) },
    {
        key = "%",
        mods = "SHIFT|CTRL",
        action = wezterm.action({ SplitHorizontal = { domain = "CurrentPaneDomain" } }),
    },
    {
        key = '"',
        mods = "SHIFT|CTRL",
        action = wezterm.action({ SplitVertical = { domain = "CurrentPaneDomain" } }),
    },
    {
        key = "H",
        mods = "ALT|CTRL",
        action = wezterm.action({ ActivatePaneDirection = "Left" }),
    },
    {
        key = "L",
        mods = "ALT|CTRL",
        action = wezterm.action({ ActivatePaneDirection = "Right" }),
    },
    {
        key = "K",
        mods = "ALT|CTRL",
        action = wezterm.action({ ActivatePaneDirection = "Up" }),
    },
    {
        key = "J",
        mods = "ALT|CTRL",
        action = wezterm.action({ ActivatePaneDirection = "Down" }),
    },
}
config.mouse_bindings = {
    {
        event = { Down = { streak = 1, button = "Right" } },
        mods = "NONE",
        action = wezterm.action_callback(function(window, pane)
            local has_selection = window:get_selection_text_for_pane(pane) ~= ""
            if has_selection then
                window:perform_action(wezterm.action.CopyTo("ClipboardAndPrimarySelection"), pane)
                window:perform_action(wezterm.action.ClearSelection, pane)
            else
                window:perform_action(wezterm.action({ PasteFrom = "Clipboard" }), pane)
            end
        end),
    },
    {
        event = { Down = { streak = 1, button = { WheelUp = 1 } } },
        mods = "NONE",
        action = action.ScrollByLine(-3),
    },
    {
        event = { Down = { streak = 1, button = { WheelDown = 1 } } },
        mods = "NONE",
        action = action.ScrollByLine(3),
    },
}

package.path = [[C:\wezterm-plugins\bar.wezterm\plugin\?.lua;C:\wezterm-plugins\bar.wezterm\plugin\?\init.lua]]
    .. package.path
local bar = wezterm.plugin.require("file:///C:/wezterm-plugins/bar.wezterm")
bar.apply_to_config(config, {
    position = "top",
    max_width = 32,
    padding = {
        left = 1,
        right = 1,
        tabs = {
            left = 0,
            right = 2,
        },
    },
    separator = {
        space = 1,
        left_icon = wezterm.nerdfonts.fa_long_arrow_right,
        right_icon = wezterm.nerdfonts.fa_long_arrow_left,
        field_icon = wezterm.nerdfonts.indent_line,
    },
    modules = {
        tabs = {
            active_tab_fg = 4,
            inactive_tab_fg = 6,
            new_tab_fg = 2,
        },
        workspace = {
            enabled = false,
        },
        leader = {
            enabled = true,
            icon = wezterm.nerdfonts.oct_rocket,
            color = 2,
        },
        pane = {
            enabled = false,
        },
        username = {
            enabled = false,
        },
        hostname = {
            enabled = false,
        },
        clock = {
            enabled = true,
        },
        cwd = {
            enabled = false,
        },
    },
})
return config
