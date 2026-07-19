-- spring-boot.nvim -- front-end for the Spring Tools language server (installed
-- as the `vscode-spring-boot-tools` mason package). Gives completion for
-- application.yml / application.properties config keys (built-in + your own
-- @ConfigurationProperties), @Value completion, and Spring bean navigation.
--
-- It plugs into jdtls: lua/config/jdtls.lua merges its bundles into jdtls'
-- init_options so the server can read your project's Spring metadata. The FULL
-- property set (e.g. spring.jpa.show-sql) comes from the jdtls CLASSPATH, so
-- jdtls must be running & imported for completion to be complete.
return {
    "JavaHello/spring-boot.nvim",
    ft = { "java", "yaml", "jproperties" },
    dependencies = {
        "mfussenegger/nvim-jdtls",
        "williamboman/mason.nvim",
    },
    config = function()
        require("spring_boot").setup({})

        -- Lazy-load race fix: this plugin starts its language server from a
        -- FileType autocmd, but the FileType event that LOADED the plugin has
        -- already fired -- so the server would never start for the very buffer
        -- you just opened. Re-fire the (now-registered) spring autocmd for the
        -- current buffer so the server attaches immediately.
        local buf = vim.api.nvim_get_current_buf()
        local ft = vim.bo[buf].filetype
        if ft == "java" or ft == "yaml" or ft == "jproperties" then
            pcall(vim.api.nvim_exec_autocmds, "FileType", {
                group = "spring_boot_ls",
                buffer = buf,
            })
        end
    end,
}
