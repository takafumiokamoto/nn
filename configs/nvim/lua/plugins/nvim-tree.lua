return {
    'nvim-tree/nvim-tree.lua',
    dependencies = 'nvim-tree/nvim-web-devicons',
    enabled = true,
    config = function()
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1

        require('nvim-tree').setup({
            view = {
                width = 30,
            },
            renderer = {
                group_empty = true
            },
            actions = {
                open_file = {
                    window_picker = {
                        enable = false,
                    }
                }
            },
            git = {
                ignore = false,
            }
        })
        vim.keymap.set('n', '<leader>ee', '<cmd>NvimTreeToggle<CR>', { desc = 'Toggle nvim-tree'})
        vim.keymap.set('n', '<leader>ef', '<cmd>NvimTreeFileToggle<CR>', { desc = 'Toggle file explorer on current file'})
        vim.keymap.set('n', '<leader>ec', '<cmd>NvimTreeCollapse<CR>', { desc = 'Collapse file explorer'})
        vim.keymap.set('n', '<leader>er', '<cmd>NvimTreeRefresh<CR>', { desc = 'Refresh file explorer'})
    end,
}
