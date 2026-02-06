return {
    cmd = { "typescript-language-server", "--stdio" },
    capabilities = require("blink.cmp").get_lsp_capabilities(),
    filetypes = {
        "javascript",
        "typescript",
        "javascriptreact",
        "typescriptreact",
    },
    root_markers = {
        ".git",
        "package.json",
        "tsconfig.json",
        "jsconfig.json",
        "next.config.js",
        "next.config.mjs",
        "next.config.ts",
    },
}
