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
        local dap_go = require("dap-go")
        local dapui = require("dapui")

        dapui.setup()
        require("nvim-dap-virtual-text").setup()

        dap_go.setup({
            delve = {
                detached = vim.fn.has("win32") == 0,
            },
        })

        vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Start or continue" })
        vim.keymap.set("n", "<S-F5>", dap.terminate, { desc = "Debug: Terminate" })
        vim.keymap.set("n", "<F9>", dap.toggle_breakpoint, { desc = "Debug: Toggle breakpoint" })
        vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: Step over" })
        vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: Step into" })
        vim.keymap.set("n", "<S-F11>", dap.step_out, { desc = "Debug: Step out" })

        vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Toggle breakpoint" })
        vim.keymap.set("n", "<leader>dB", function()
            vim.ui.input({ prompt = "Breakpoint condition: " }, function(condition)
                if condition and condition ~= "" then
                    dap.set_breakpoint(condition)
                end
            end)
        end, { desc = "Debug: Set conditional breakpoint" })
        vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Debug: Start or continue" })
        vim.keymap.set("n", "<leader>dC", dap.run_to_cursor, { desc = "Debug: Run to cursor" })
        vim.keymap.set("n", "<leader>de", dapui.eval, { desc = "Debug: Evaluate expression" })
        vim.keymap.set("x", "<leader>de", dapui.eval, { desc = "Debug: Evaluate selection" })
        vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Debug: Toggle UI" })
        vim.keymap.set("n", "<leader>dx", dap.terminate, { desc = "Debug: Terminate" })

        local go_keymaps = vim.api.nvim_create_augroup("dap_go_keymaps", { clear = true })
        vim.api.nvim_create_autocmd("FileType", {
            group = go_keymaps,
            pattern = "go",
            callback = function(event)
                vim.keymap.set("n", "<leader>dt", dap_go.debug_test, {
                    buffer = event.buf,
                    desc = "Debug: Nearest Go test",
                })
                vim.keymap.set("n", "<leader>dT", dap_go.debug_last_test, {
                    buffer = event.buf,
                    desc = "Debug: Last Go test",
                })
            end,
        })

        dap.listeners.before.attach.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated.dapui_config = function()
            dapui.close()
        end
        dap.listeners.before.event_exited.dapui_config = function()
            dapui.close()
        end
    end,
}
