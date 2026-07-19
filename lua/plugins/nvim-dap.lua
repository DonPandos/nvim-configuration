return {
    "mfussenegger/nvim-dap",
    dependencies = {
        -- ui plugins to make debugging simplier
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio"
    },
    config = function()
        local dap = require("dap")
        local dapui = require("dapui")

        dapui.setup()

        -- Breakpoint / stopped-line signs (IntelliJ-style markers)
        vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticError", numhl = "" })
        vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "DiagnosticWarn", numhl = "" })
        vim.fn.sign_define("DapLogPoint", { text = "", texthl = "DiagnosticInfo", numhl = "" })
        vim.fn.sign_define("DapStopped", { text = "", texthl = "DiagnosticWarn", linehl = "Visual", numhl = "" })

        -- Auto-open the UI when a session starts, auto-close when it ends.
        dap.listeners.before.attach.dapui_config = function() dapui.open() end
        dap.listeners.before.launch.dapui_config = function() dapui.open() end
        dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
        dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

        local map = function(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { desc = desc })
        end

        -- Breakpoints
        map("<leader>dt", dap.toggle_breakpoint, "[D]ebug [T]oggle Breakpoint")
        map("<leader>dB", function()
            dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end, "[D]ebug Conditional [B]reakpoint")

        -- Start / control flow
        map("<leader>ds", dap.continue, "[D]ebug [S]tart / Continue")
        map("<leader>dc", dap.continue, "[D]ebug [C]ontinue")
        map("<leader>di", dap.step_into, "[D]ebug Step [I]nto")
        map("<leader>do", dap.step_over, "[D]ebug Step [O]ver")
        map("<leader>dO", dap.step_out, "[D]ebug Step [O]ut (up)")
        map("<leader>dl", dap.run_last, "[D]ebug Run [L]ast")

        -- UI: toggle the debug windows back open/closed (fixes "can't reopen")
        map("<leader>du", dapui.toggle, "[D]ebug Toggle [U]I")
        map("<leader>de", function() dapui.eval(nil, { enter = true }) end, "[D]ebug [E]valuate")
        map("<leader>dr", dap.repl.toggle, "[D]ebug [R]EPL")

        -- Stop: terminate the debuggee (shuts the application down) and close UI
        map("<leader>dx", function()
            dap.terminate()
            dap.close()
            dapui.close()
        end, "[D]ebug Stop / Terminate (shutdown app)")

        -- Familiar function keys (VSCode-style)
        map("<F5>", dap.continue, "Debug: Continue")
        map("<F10>", dap.step_over, "Debug: Step Over")
        map("<F11>", dap.step_into, "Debug: Step Into")
        map("<S-F11>", dap.step_out, "Debug: Step Out")
        map("<S-F5>", function()
            dap.terminate()
            dap.close()
            dapui.close()
        end, "Debug: Stop")
    end
}
