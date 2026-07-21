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

            -- References with an optional "skip tests" filter (IntelliJ's scope
            -- selector). is_test_file matches the Maven/Gradle test source roots
            -- and the usual test-class name suffixes.
            local function is_test_file(filename)
                if not filename then
                    return false
                end
                return filename:find("/src/test/", 1, true) ~= nil
                    or filename:find("/src/integration-test/", 1, true) ~= nil
                    or filename:find("/src/testFixtures/", 1, true) ~= nil
                    or filename:match("Test%.java$") ~= nil
                    or filename:match("Tests%.java$") ~= nil
                    or filename:match("IT%.java$") ~= nil
                    or filename:match("ITCase%.java$") ~= nil
            end

            -- Telescope references picker. When include_tests is false we drop
            -- every reference living in a test source set: telescope's finder
            -- skips any row whose entry_maker returns nil (validated against
            -- async_static_finder). The list layout (filename-first, no code
            -- line) is inherited from the pickers.lsp_references config.
            local make_entry = require("telescope.make_entry")
            local function references(include_tests)
                return function()
                    local opts = { show_line = false }
                    local base = make_entry.gen_from_quickfix(opts)
                    opts.entry_maker = function(line)
                        local entry = base(line)
                        if entry == nil then
                            return nil
                        end
                        if not include_tests and is_test_file(entry.filename) then
                            return nil
                        end
                        return entry
                    end
                    require("telescope.builtin").lsp_references(opts)
                end
            end

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
                    map("n", "<leader>cr", references(false), "[C]ode [R]eferences (skip tests)")
                    map("n", "<leader>cR", references(true), "[C]ode [R]eferences (all, incl. tests)")
                    map("n", "<leader>ci", telescope.lsp_implementations, "[C]ode Goto [I]mplementations")
                    -- rename moved off <leader>cR (now "all references") to <leader>cn ("re[n]ame")
                    map("n", "<leader>cn", vim.lsp.buf.rename, "[C]ode Re[n]ame")
                    map("n", "<leader>cD", vim.lsp.buf.declaration, "[C]ode Goto [D]eclaration")
                    map("n", "<leader>cs", telescope.lsp_document_symbols, "[C]ode [S]ymbols")

                    -- Jump between diagnostics (0.11 API; goto_prev/next are deprecated)
                    map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Prev Diagnostic")
                    map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next Diagnostic")

                    -- Inlay hints (IntelliJ-style parameter/type hints) if supported
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    if client and client:supports_method("textDocument/inlayHint") then
                        vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })

                        -- Toggle inlay hints for THIS buffer. On Neovim 0.12.4 the
                        -- inlay-hint decoration provider can throw "Invalid 'col':
                        -- out of range" when a server reports a hint past the end of
                        -- a line (a core bug). It's cosmetic, but if a file gets
                        -- noisy, flip hints off here to silence it.
                        map("n", "<leader>cH", function()
                            local on = vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf })
                            vim.lsp.inlay_hint.enable(not on, { bufnr = args.buf })
                        end, "[C]ode Toggle Inlay [H]ints")
                    end

                    -- Highlight every usage of the symbol under the cursor, like
                    -- IntelliJ's "highlight usages". On CursorHold the server
                    -- (jdtls, vtsls, ...) returns all occurrences via
                    -- textDocument/documentHighlight; we clear them when the cursor
                    -- moves. Colors come from LspReferenceRead/Write/Text, which
                    -- jb.nvim maps to IntelliJ's real IdentifierUnderCaret colors.
                    -- (Delay = 'updatetime', which is 100ms in your options.)
                    if client and client:supports_method("textDocument/documentHighlight") then
                        local hl_augroup = vim.api.nvim_create_augroup(
                            "lsp_doc_highlight_" .. args.buf, { clear = true }
                        )
                        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                            group = hl_augroup,
                            buffer = args.buf,
                            callback = vim.lsp.buf.document_highlight,
                        })
                        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                            group = hl_augroup,
                            buffer = args.buf,
                            callback = vim.lsp.buf.clear_references,
                        })
                    end
                end,
            })
        end,
    },
}
