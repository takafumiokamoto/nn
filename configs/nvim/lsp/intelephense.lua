return {
    cmd = { "intelephense", "--stdio" },
    capabilities = require("blink.cmp").get_lsp_capabilities(),
    filetypes = { "php" },
    root_markers = { "composer.json", ".git" },
    settings = {
        intelephense = {
            files = {
                maxSize = 5000000,
            },
        },
    },
}
