return {
    "elmcgill/springboot-nvim",
    dependencies = {
        "neovim/nvim-lspconfig",
        "mfussenegger/nvim-jdtls"
    },
    config = function()
        -- gain acces to the springboot nvim plugin and its functions
        local springboot_nvim = require("springboot-nvim")

        -- The plugin's boot_run opens `split | terminal` (which fires TermOpen)
        -- and then sends `mvn spring-boot:run` to that terminal's job. It has NO
        -- stop function, so we track the terminal we launch and stop it ourselves.
        -- A one-shot flag marks the TermOpen that belongs to OUR boot_run call.
        local boot = { job = nil, buf = nil }
        local capture_next = false
        vim.api.nvim_create_autocmd("TermOpen", {
            callback = function(ev)
                if capture_next then
                    boot.buf = ev.buf
                    boot.job = vim.b[ev.buf].terminal_job_id
                    capture_next = false
                end
            end,
        })

        local function boot_run()
            capture_next = true
            springboot_nvim.boot_run()
            capture_next = false
        end

        -- Stop the running app by sending Ctrl-C (SIGINT, byte 0x03) to the
        -- terminal -- exactly like pressing Ctrl-C in it, so Maven runs its
        -- shutdown hook and Spring stops gracefully. We deliberately do NOT use
        -- jobstop() (SIGTERM/SIGKILL): that skips the shutdown hook and can leave
        -- the forked JVM orphaned.
        local function boot_stop()
            if boot.job and boot.buf and vim.api.nvim_buf_is_valid(boot.buf) then
                local ok = pcall(vim.fn.chansend, boot.job, "\003")
                if ok then
                    vim.notify("Spring Boot: sent Ctrl-C (graceful shutdown)")
                    return
                end
            end
            vim.notify("Spring Boot: no running app tracked (start it with <leader>Jr)", vim.log.levels.WARN)
        end

        -- set a vim motion to <Space> + <Shift>J + r to run the spring boot project in a vim terminal
        vim.keymap.set('n', '<leader>Jr', boot_run, {desc = "[J]ava [R]un Spring Boot"})
        -- set a vim motion to <Space> + <Shift>J + s to stop the running spring boot app
        vim.keymap.set('n', '<leader>Js', boot_stop, {desc = "[J]ava [S]top Spring Boot"})
        -- set a vim motion to <Space> + <Shift>J + c to open the generate class ui to create a class
        vim.keymap.set('n', '<leader>Jc', springboot_nvim.generate_class, {desc = "[J]ava Create [C]lass"})
        -- set a vim motion to <Space> + <Shift>J + i to open the generate interface ui to create an interface
        vim.keymap.set('n', '<leader>Ji', springboot_nvim.generate_interface, {desc = "[J]ava Create [I]nterface"})
        -- set a vim motion to <Space> + <Shift>J + e to open the generate enum ui to create an enum
        vim.keymap.set('n', '<leader>Je', springboot_nvim.generate_enum, {desc = "[J]ava Create [E]num"})

        -- run the setup function with default configuration
        springboot_nvim.setup({})
    end
}
