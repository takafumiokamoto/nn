return {
    cmd = {
        "rust-analyzer",
    },
    capabilities = require("blink.cmp").get_lsp_capabilities(),
    filetypes = {
        "rust",
    },
    root_markers = {
        ".git",
        "Cargo.toml",
    },
    settings = {
        ["rust-analyzer"] = {},
    },
}
