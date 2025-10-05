return {
    'nvim-telescope/telescope.nvim',
    dependencies = {
        'nvim-lua/plenary.nvim',
    },
    {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = function()
            vim.env.CC = 'zig cc',
            vim.fn.system('cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release')
        end
    }
}
