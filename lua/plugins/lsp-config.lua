return {
    -- Mason installs & manages external tooling (LSP servers, DAP adapters,
    -- linters, formatters). NOTE: the `williamboman/*` repos now redirect to
    -- `mason-org/*` (same code, v2) -- keeping the old URL avoids a double-clone
    -- with plugins that still depend on `williamboman/mason.nvim`.
    {
        "williamboman/mason.nvim",
        build = ":MasonUpdate",
        opts = {},
    },

    -- Dedicated Java language server. This is the ONLY thing allowed to attach
    -- to Java files (configured in lua/config/jdtls.lua). Because it launches
    -- jdtls with the Lombok javaagent, generated getters/setters/@Slf4j etc. are
    -- understood -- which is why we must NOT let mason auto-enable a second,
    -- Lombok-unaware Java server (that was the source of the false "unused" /
    -- Lombok import warnings).
    {
        "mfussenegger/nvim-jdtls",
        dependencies = { "mfussenegger/nvim-dap" },
    },

    -- Debug adapters via mason
    {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = { "williamboman/mason.nvim" },
        opts = {
            ensure_installed = { "java-debug-adapter", "java-test" },
        },
    },

    -- The LSP layer. On Neovim 0.11+ the `require('lspconfig')` framework is
    -- deprecated; nvim-lspconfig is now a data-only repo and we drive servers
    -- with the native `vim.lsp.config` / `vim.lsp.enable` API.
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason-lspconfig.nvim",
            "WhoIsSethDaniel/mason-tool-installer.nvim",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            -- Advertise the extra capabilities nvim-cmp adds (snippets, etc.)
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            -- 1. Defaults applied to EVERY server we enable ("*") --------------
            vim.lsp.config("*", {
                capabilities = capabilities,
            })

            -- 2. Per-server overrides (merged on top of what lspconfig ships) --
            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = {
                        diagnostics = { globals = { "vim" } },
                        workspace = { checkThirdParty = false },
                        telemetry = { enable = false },
                    },
                },
            })

            -- vtsls: a richer TypeScript/JavaScript server than ts_ls. Turn on
            -- inlay hints so it feels like IntelliJ (parameter / type hints).
            vim.lsp.config("vtsls", {
                settings = {
                    typescript = {
                        inlayHints = {
                            parameterNames = { enabled = "literals" },
                            variableTypes = { enabled = true },
                            propertyDeclarationTypes = { enabled = true },
                            functionLikeReturnTypes = { enabled = true },
                        },
                    },
                    javascript = {
                        inlayHints = {
                            parameterNames = { enabled = "literals" },
                            variableTypes = { enabled = true },
                        },
                    },
                },
            })

            -- 3. Ensure servers + CLI tools are installed --------------------
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "lua_ls", "vtsls", "terraformls", "jsonls",
                    "yamlls", "marksman", "dockerls", "bashls",
                },
                -- We enable servers explicitly (step 4) instead of letting mason
                -- auto-enable everything -- that guarantees jdtls / java-language-
                -- server never auto-start and fight nvim-jdtls over Java files.
                automatic_enable = false,
            })

            require("mason-tool-installer").setup({
                ensure_installed = {
                    "stylua",              -- lua formatter
                    "prettierd",           -- js/ts/json/yaml/md/html/css formatter
                    "eslint_d",            -- js/ts linter
                    "shfmt",               -- shell formatter
                    "tflint",              -- terraform linter
                    "hadolint",            -- dockerfile linter
                    "markdownlint-cli2",   -- markdown linter
                    "java-debug-adapter",
                    "java-test",
                },
                run_on_start = true,
            })

            -- 4. Turn the servers on (jdtls is intentionally absent) ---------
            vim.lsp.enable({
                "lua_ls", "vtsls", "terraformls", "jsonls",
                "yamlls", "marksman", "dockerls", "bashls",
            })

            -- 5. Diagnostics UI -- inline errors like IntelliJ ---------------
            vim.diagnostic.config({
                virtual_text = { spacing = 2, prefix = "●" },
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = "",
                        [vim.diagnostic.severity.WARN] = "",
                        [vim.diagnostic.severity.INFO] = "",
                        [vim.diagnostic.severity.HINT] = "",
                    },
                },
                underline = true,
                update_in_insert = false,
                severity_sort = true,
                float = { border = "rounded", source = true },
            })

            -- 6. Buffer-local keymaps + inlay hints, only where a server
            --    actually attached (see :help lsp-attach).
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local map = function(mode, lhs, rhs, desc)
                        vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, desc = desc })
                    end
                    local telescope = require("telescope.builtin")

                    map("n", "<leader>ch", vim.lsp.buf.hover, "[C]ode [H]over Documentation")
                    map("n", "<leader>cd", vim.lsp.buf.definition, "[C]ode Goto [D]efinition")
                    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ctions")
                    map("n", "<leader>cr", telescope.lsp_references, "[C]ode Goto [R]eferences")
                    map("n", "<leader>ci", telescope.lsp_implementations, "[C]ode Goto [I]mplementations")
                    map("n", "<leader>cR", vim.lsp.buf.rename, "[C]ode [R]ename")
                    map("n", "<leader>cD", vim.lsp.buf.declaration, "[C]ode Goto [D]eclaration")
                    map("n", "<leader>cs", telescope.lsp_document_symbols, "[C]ode [S]ymbols")

                    -- Jump between diagnostics (0.11 API; goto_prev/next are deprecated)
                    map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Prev Diagnostic")
                    map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next Diagnostic")

                    -- Inlay hints (IntelliJ-style parameter/type hints) if supported
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    if client and client:supports_method("textDocument/inlayHint") then
                        vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
                    end
                end,
            })
        end,
    },
}
