return {
    cmd = { "vscode-eslint-language-server", "--stdio" },
    capabilities = require("blink.cmp").get_lsp_capabilities(),
    filetypes = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
    },
    root_markers = {
        "eslint.config.js",
        "eslint.config.mjs",
        "eslint.config.cjs",
        "eslint.config.ts",
        ".eslintrc",
        ".eslintrc.js",
        ".eslintrc.cjs",
        ".eslintrc.json",
        ".eslintrc.yaml",
        ".eslintrc.yml",
        "package.json",
        ".git",
    },
}

