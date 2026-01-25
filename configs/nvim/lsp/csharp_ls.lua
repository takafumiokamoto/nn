return {
    cmd = { "csharp-ls" },
    capabilities = require("blink.cmp").get_lsp_capabilities(),
    filetypes = { "cs" },
    root_markers = { "*.sln", "*.csproj", ".git" },
}
