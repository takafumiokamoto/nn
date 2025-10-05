return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio",
        "leoluz/nvim-dap-go",
        "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
        local dap = require("dap")
        local ui = require("dapui")
        require("dap-go").setup({
            delve = {
                detached = vim.fn.has("win32") == 0,
            },
        })
        vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint)
        vim.keymap.set("n", "<leader>gb", dap.run_to_cursor)

        vim.keymap.set("n", "<leader>dc", dap.continue)
        vim.keymap.set("n", "<leader>di", dap.step_into)
        vim.keymap.set("n", "<F10>", dap.step_over)
        vim.keymap.set("n", "<leader>do", dap.step_out)
        vim.keymap.set("n", "<leader>db", dap.step_back)
        vim.keymap.set("n", "<leader>dr", dap.restart)

        dap.listeners.before.attach.dapui_config = function()
            ui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
            ui.open()
        end
        dap.listeners.before.event_terminated.dapui_config = function()
            ui.close()
        end
        dap.listeners.before.event_exited.dapui_config = function()
            ui.close()
        end
    end,
}
