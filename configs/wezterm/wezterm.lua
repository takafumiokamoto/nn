local wezterm = require("wezterm")
local mux = wezterm.mux
local config = wezterm.config_builder()

config.font_size = 11
config.font_dirs = {
    wezterm.config_dir .. "/fonts",
}
config.font = wezterm.font_with_fallback({
    { family = "Moralerspace Neon JPDOC", italic = true, weight = "Bold" },
})
--config.color_scheme = "Palenight (Gogh)"
 config.color_scheme = "DoomOne"
config.hide_tab_bar_if_only_one_tab = true
config.audible_bell = "Disabled"
config.notification_handling = "NeverShow"
config.use_ime = true
-- config.default_domain = 'WSL:Debian'
config.default_domain = "WSL:Ubuntu-26.04"
--config.default_prog = { "pwsh.exe" }
config.window_background_opacity = 1
config.automatically_reload_config = true
config.cursor_blink_rate = 0
config.default_cursor_style = 'SteadyBlock'
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
    { key = "Enter", mods = "SHIFT", action = wezterm.action({ SendString = "\n" }) },
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
        mods = "SHIFT|CTRL",
        action = wezterm.action({ ActivatePaneDirection = "Left" }),
    },
    {
        key = "L",
        mods = "SHIFT|CTRL",
        action = wezterm.action({ ActivatePaneDirection = "Right" }),
    },
    {
        key = "K",
        mods = "SHIFT|CTRL",
        action = wezterm.action({ ActivatePaneDirection = "Up" }),
    },
    {
        key = "J",
        mods = "SHIFT|CTRL",
        action = wezterm.action({ ActivatePaneDirection = "Down" }),
    },
    {
        key = "LeftArrow",
        mods = "SHIFT",
        action = wezterm.action({ AdjustPaneSize = { "Left", 5 } }),
    },
    {
        key = "RightArrow",
        mods = "SHIFT",
        action = wezterm.action({ AdjustPaneSize = { "Right", 5 } }),
    },
    {
        key = "UpArrow",
        mods = "SHIFT",
        action = wezterm.action({ AdjustPaneSize = { "Up", 5 } }),
    },
    {
        key = "DownArrow",
        mods = "SHIFT",
        action = wezterm.action({ AdjustPaneSize = { "Down", 5 } }),
    },
    {
        key = "PageDown",
        action = wezterm.action({ ScrollByPage = 0.25 }),
    },
    {
        key = "PageUp",
        action = wezterm.action({ ScrollByPage = -0.25 }),
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

local bar = wezterm.plugin.require("https://github.com/adriankarlen/bar.wezterm")
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
