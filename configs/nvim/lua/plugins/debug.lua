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

        -- C# / .NET configuration
        dap.adapters.coreclr = {
            type = "executable",
            command = "netcoredbg",
            args = { "--interpreter=vscode" },
        }
        dap.configurations.cs = {
            {
                type = "coreclr",
                name = "Launch",
                request = "launch",
                program = function()
                    return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
                end,
            },
        }

        -- PHP configuration (requires Xdebug)
        dap.adapters.php = {
            type = "executable",
            command = "php-debug-adapter",
        }
        dap.configurations.php = {
            {
                type = "php",
                request = "launch",
                name = "Listen for Xdebug",
                port = 9003,
            },
        }
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
