return {
    cmd = {
        "clangd",
    },
    capabilities = require("blink.cmp").get_lsp_capabilities(),
    filetypes = {
        "c",
        "cpp",
    },
    root_markers = {
        ".git",
        "compile_comands.json",
        "compile_flags.json",
        "CMakeLists.txt",
    },
    settings = {
        clangd = {},
    },
}
