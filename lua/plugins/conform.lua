-- conform.nvim -- the formatting engine (replaces none-ls formatting).
-- Formatters are installed via mason-tool-installer (see lsp-config.lua).
--
-- Java is intentionally NOT listed here: on <leader>cf, conform finds no Java
-- formatter and (because of lsp_format = "fallback") hands off to jdtls, which
-- uses the Eclipse formatter profile tuned to your IntelliJ style
-- (lang_servers/intellij-java-style.xml, wired in lua/config/jdtls.lua).
return {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
        {
            "<leader>cf",
            function()
                require("conform").format({ async = true, lsp_format = "fallback" })
            end,
            mode = { "n", "v" },
            desc = "[C]ode [F]ormat",
        },
    },
    opts = {
        formatters_by_ft = {
            lua = { "stylua" },
            -- `stop_after_first` = use prettierd if present, else prettier
            javascript = { "prettierd", "prettier", stop_after_first = true },
            javascriptreact = { "prettierd", "prettier", stop_after_first = true },
            typescript = { "prettierd", "prettier", stop_after_first = true },
            typescriptreact = { "prettierd", "prettier", stop_after_first = true },
            json = { "prettierd", "prettier", stop_after_first = true },
            jsonc = { "prettierd", "prettier", stop_after_first = true },
            yaml = { "prettierd", "prettier", stop_after_first = true },
            html = { "prettierd", "prettier", stop_after_first = true },
            css = { "prettierd", "prettier", stop_after_first = true },
            markdown = { "prettierd", "prettier", stop_after_first = true },
            terraform = { "terraform_fmt" },
            hcl = { "terraform_fmt" },
            tf = { "terraform_fmt" },
            sh = { "shfmt" },
            bash = { "shfmt" },
            -- java -> handled by jdtls via the lsp_format fallback (see note above)
        },
        format_on_save = function(bufnr)
            -- Don't auto-reformat Java on save (avoid surprise reindentation);
            -- jdtls still organizes imports on save, and <leader>cf reformats on
            -- demand. Everything else formats on save.
            if vim.bo[bufnr].filetype == "java" then
                return nil
            end
            return { timeout_ms = 2000, lsp_format = "fallback" }
        end,
    },
}
