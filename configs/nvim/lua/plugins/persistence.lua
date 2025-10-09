return {
    'folke/persistence.nvim',
    config = function()
        persistence = require('persistence')
        vim.keymap.set('n', '<leader>qs', function() persistence.load() end, { desc = 'load session for cwd'})
        vim.keymap.set('n', '<leader>qS', function() persistence.load() end, { desc = 'select a session to load'})
        vim.keymap.set('n', '<leader>ql', function() persistence.load() end, { desc ='load the last session'})
        vim.keymap.set('n', '<leader>qd', function() persistence.load() end, { desc = 'stop persistence.nvim'})
    end
}
