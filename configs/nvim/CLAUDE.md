# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a modern Neovim configuration using **lazy.nvim** as the plugin manager. The configuration is modular, with clear separation between core settings, LSP configurations, and plugin specifications.

## Architecture

### Loading Sequence

`init.lua` orchestrates the initialization in this order:
1. `require("core.lazy")` - Bootstraps lazy.nvim, sets leader keys, loads all plugins from `lua/plugins/`
2. `require("core.options")` - Applies Vim settings
3. `require("core.keymaps")` - Registers global keybindings
4. `require("lsp")` - Enables LSP servers via `vim.lsp.enable()`
5. `require("core.neovide")` - GUI-specific config (conditional)

### Directory Structure

```
lua/
├── core/           # Foundational configuration
│   ├── lazy.lua    # Plugin manager bootstrap & setup
│   ├── options.lua # Vim options (vim.opt settings)
│   ├── keymaps.lua # Global keybindings
│   └── neovide.lua # Neovide GUI config
├── lsp/            # LSP server configurations
│   ├── init.lua    # Enables servers via vim.lsp.enable()
│   ├── lua_ls.lua  # Lua language server config
│   └── gopls.lua   # Go language server config
└── plugins/        # Plugin specifications (lazy.nvim format)
    ├── blink-cmp.lua
    ├── mason.lua
    ├── telescope.lua
    └── ...
```

### Module Patterns

**Plugins** (`lua/plugins/*.lua`):
- Each file returns a lazy.nvim plugin specification table
- Format: `return { "author/plugin", event = "...", config = function() ... end }`
- Automatically discovered by lazy.nvim via `lazy.setup({ import = "plugins" })`

**LSP Servers** (`lua/lsp/*.lua`):
- Each file returns a configuration table (NOT a plugin spec)
- Must be enabled in `lua/lsp/init.lua` via `vim.lsp.enable({ "servername" })`
- Use `require("blink.cmp").get_lsp_capabilities()` for completion integration

**Core** (`lua/core/*.lua`):
- Pure configuration modules (options, keymaps, etc.)
- Loaded directly via `require()` from `init.lua`

## Adding New Components

### Adding a Plugin

1. Create `lua/plugins/newplugin.lua`:
```lua
return {
    "author/plugin-name",
    event = "VimEnter",  -- or cmd, ft, keys, etc.
    config = function()
        -- setup code
    end,
}
```
2. Lazy.nvim auto-discovers and loads it

### Adding an LSP Server

1. Create `lua/lsp/servername.lua`:
```lua
return {
    name = "servername",
    cmd = { "server-executable" },
    root_markers = { ".git", "config-file" },
    capabilities = require("blink.cmp").get_lsp_capabilities(),
    settings = {
        -- server-specific settings
    },
}
```
2. Enable in `lua/lsp/init.lua`:
```lua
vim.lsp.enable({
    "gopls",
    "lua_ls",
    "servername",  -- add here
})
```
3. Add to Mason auto-install in `lua/plugins/mason.lua` if needed

## Key Conventions

### Leader Key Namespaces

- Leader = Space
- `<leader>f` - Telescope (find files, grep, buffers, etc.)
- `<leader>e` - nvim-tree (toggle, focus, collapse, refresh)
- `<leader>t` - Tabs (open, close, next, prev)
- `<leader>s` - Splits (vertical, horizontal, equal, close)
- `<leader>nh` - Clear search highlights

### Lazy Loading Strategy

- **Colorscheme**: No lazy load (priority 1000, loaded first)
- **Telescope**: Lazy load on VimEnter
- **nvim-tree**: Default lazy load (on first use)
- **autopairs**: Lazy load on InsertEnter
- **blink-cmp**: Capabilities must be passed to LSP servers

### Tool Management

Mason auto-installs tools based on available interpreters:
- Always: lua-language-server, stylua, prettier
- If Go available: gopls, delve, golangci-lint
- If Python available: ruff, pyright, debugpy

Configured in `lua/plugins/mason.lua` with conditional installation logic.

## Important Files

- `init.lua` - Main entry point
- `lazy-lock.json` - Plugin versions (auto-managed, commit this file)
- `lua/core/lazy.lua` - Plugin manager initialization
- `lua/lsp/init.lua` - LSP server enablement (single source of truth)

## LSP Capability Integration

All LSP server configs should include:
```lua
capabilities = require("blink.cmp").get_lsp_capabilities()
```

This ensures completion works correctly with blink.cmp (the configured completion engine).

## Configuration Philosophy

This config prioritizes:
- **Modularity**: Each component is self-contained
- **Lazy loading**: Plugins load only when needed
- **Explicit dependencies**: All dependencies declared in plugin specs
- **Conditional features**: Tools/configs load based on environment (e.g., Neovide, Python/Go availability)
- **Single responsibility**: Each file has one clear purpose
