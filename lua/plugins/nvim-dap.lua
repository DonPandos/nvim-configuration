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

        -- Breakpoint / stopped-line signs. Use plain Unicode (●, ◆, ▶) instead
        -- of Nerd-Font glyphs so they render in ANY font, with explicit bright
        -- colors so they show even on terminals that mangle the theme.
        vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#e51400" })
        vim.api.nvim_set_hl(0, "DapBreakpointCondition", { fg = "#f79000" })
        vim.api.nvim_set_hl(0, "DapLogPoint", { fg = "#61afef" })
        vim.api.nvim_set_hl(0, "DapStopped", { fg = "#98c379" })
        vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", numhl = "" })
        vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DapBreakpointCondition", numhl = "" })
        vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DapLogPoint", numhl = "" })
        vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DapStopped", linehl = "Visual", numhl = "" })

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

        -- Run a launch config WITHOUT the debugger -- the equivalent of VSCode's
        -- "Run Without Debugging" (Ctrl+F5). nvim-dap sends the whole config
        -- table as the DAP `launch` request body, so setting `noDebug = true`
        -- tells the adapter to start the program but skip breakpoints/stepping.
        -- Pulls choices from .vscode/launch.json (auto-read) plus any configs
        -- registered for the current filetype (e.g. jdtls's main-class configs).
        local function run_without_debug()
            local ft = vim.bo.filetype
            local configs = {}
            vim.list_extend(configs, dap.configurations[ft] or {})
            local ok, launch = pcall(function()
                return require("dap.ext.vscode").getconfigs()
            end)
            if ok and launch then
                vim.list_extend(configs, launch)
            end
            if #configs == 0 then
                vim.notify("No launch configurations found for '" .. ft .. "'", vim.log.levels.WARN)
                return
            end
            require("dap.ui").pick_one(
                configs,
                "Run WITHOUT debugging: ",
                function(c) return string.format("%s (%s)", c.name, c.type) end,
                function(choice)
                    if not choice then return end
                    local cfg = vim.deepcopy(choice)
                    cfg.noDebug = true -- <- the "just run it" switch
                    dap.run(cfg)
                end
            )
        end
        map("<leader>dR", run_without_debug, "[D]ebug [R]un (no debugger / Ctrl+F5)")

        -- UI: toggle the debug windows back open/closed (fixes "can't reopen")
        map("<leader>du", dapui.toggle, "[D]ebug Toggle [U]I")
        map("<leader>de", function() dapui.eval(nil, { enter = true }) end, "[D]ebug [E]valuate")
        map("<leader>dr", dap.repl.toggle, "[D]ebug [R]EPL")

        -- Stop: terminate the debuggee (shuts the application down), then close
        -- the session/UI ONLY in the callback -- i.e. after the terminate request
        -- has actually been sent. Calling dap.close() immediately (as before)
        -- raced the async terminate and orphaned the running app.
        local function stop_debug()
            if not dap.session() then
                dapui.close()
                return
            end
            dap.terminate(nil, { terminateDebuggee = true }, function()
                dap.close()
                dapui.close()
            end)
        end
        map("<leader>dx", stop_debug, "[D]ebug Stop / Terminate (shutdown app)")

        -- Hard kill: if a session is wedged and terminate won't take, force a
        -- disconnect that also kills the debuggee.
        map("<leader>dX", function()
            dap.disconnect({ terminateDebuggee = true })
            dap.close()
            dapui.close()
        end, "[D]ebug Force Kill (disconnect)")

        -- Familiar function keys (VSCode-style)
        map("<F5>", dap.continue, "Debug: Continue")
        map("<F10>", dap.step_over, "Debug: Step Over")
        map("<F11>", dap.step_into, "Debug: Step Into")
        map("<S-F11>", dap.step_out, "Debug: Step Out")
        map("<S-F5>", stop_debug, "Debug: Stop")
    end
}
