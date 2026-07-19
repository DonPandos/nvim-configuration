-- nvim-lint -- standalone linters that complement the LSP diagnostics.
-- Linter binaries are installed via mason-tool-installer (see lsp-config.lua).
return {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile", "BufWritePost" },
    config = function()
        local lint = require("lint")

        lint.linters_by_ft = {
            terraform = { "tflint" },
            tf = { "tflint" },
            dockerfile = { "hadolint" },
            markdown = { "markdownlint-cli2" },
            javascript = { "eslint_d" },
            javascriptreact = { "eslint_d" },
            typescript = { "eslint_d" },
            typescriptreact = { "eslint_d" },
        }

        local lint_augroup = vim.api.nvim_create_augroup("nvim-lint", { clear = true })
        vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
            group = lint_augroup,
            callback = function()
                -- only lint if a linter is configured for this filetype
                if lint.linters_by_ft[vim.bo.filetype] then
                    lint.try_lint()
                end
            end,
        })
    end,
}
