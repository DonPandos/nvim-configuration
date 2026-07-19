return {
    {
        "L3MON4D3/LuaSnip",
        dependencies = {
            -- feed luasnip suggestions to cmp
            "saadparwaiz1/cmp_luasnip",
            -- provide vscode like snippets to cmp
            "rafamadriz/friendly-snippets",
        }
    },
    -- cmp-nvim-lsp provides language specific completion suggestions to nvim-cmp
    {
        "hrsh7th/cmp-nvim-lsp",
    },
    -- nvim-cmp provides auto completion and auto completion dropdown ui
    {
        "hrsh7th/nvim-cmp",
        -- CmdlineEnter is needed so cmdline completion (":", "/") is active the
        -- first time you open the command line, not only after entering insert.
        event = { "InsertEnter", "CmdlineEnter" },
        dependencies = {
            -- buffer based completion options
            "hrsh7th/cmp-buffer",
            -- path based completion options
            "hrsh7th/cmp-path",
            -- completion in the ":" command line and "/" search
            "hrsh7th/cmp-cmdline",
            -- show function signature (arg being typed) as a completion source
            "hrsh7th/cmp-nvim-lsp-signature-help",
            -- VSCode/IntelliJ-like icons in the completion menu
            "onsails/lspkind.nvim",
        },
        config = function()
            -- Gain access to the functions of the cmp plugin
            local cmp = require("cmp")
            -- Gain access to the function of the luasnip plugin
            local luasnip = require("luasnip")
            local lspkind = require("lspkind")

            -- Lazily load the vscode like snippets
            require("luasnip.loaders.from_vscode").lazy_load()

            -- These source plugins register themselves via after/plugin/*.lua,
            -- which lazy.nvim does NOT reliably source for lazy-loaded deps -- so
            -- the buffer/path/cmdline sources silently never register (that's why
            -- cmdline completion showed nothing). Register them explicitly here.
            pcall(function() cmp.register_source("buffer", require("cmp_buffer")) end)
            pcall(function() cmp.register_source("path", require("cmp_path").new()) end)
            pcall(function() cmp.register_source("cmdline", require("cmp_cmdline").new()) end)
            pcall(function()
                cmp.register_source("nvim_lsp_signature_help", require("cmp_nvim_lsp_signature_help").new())
            end)

            -- All the cmp setup function to configure our completion experience
            cmp.setup({
                -- How should completion options be displayed to us?
                completion = {
                    -- (fixed typo: was `competeopt`, so this was silently ignored)
                    completeopt = "menu,menuone,preview,noselect"
                },
                -- "grep-like" matching: match the typed text ANYWHERE in a
                -- candidate (not just as a prefix), so typing "show" surfaces
                -- "spring.jpa.show-sql" and "La" surfaces every command with "la".
                matching = {
                    disallow_fuzzy_matching = false,
                    disallow_fullfuzzy_matching = false,
                    disallow_partial_fuzzy_matching = false,
                    disallow_partial_matching = false,
                    disallow_prefix_unmatching = false,
                    disallow_symbol_nonprefix_matching = false,
                },
                -- setup snippet support based on the active lsp and the current text of the file
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end
                },
                -- Bordered popups (looks like IntelliJ's completion popup)
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                -- Icon + text formatting for each entry
                formatting = {
                    format = lspkind.cmp_format({
                        mode = "symbol_text",
                        maxwidth = 50,
                        ellipsis_char = "...",
                    }),
                },
                -- setup how we interact with completion menus and options
                mapping = cmp.mapping.preset.insert({
                     -- previous suggestion
                    ["<C-k>"] = cmp.mapping.select_prev_item(),
                    -- next suggestion
                    ["<C-j>"] = cmp.mapping.select_next_item(),
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    -- show completion suggestions (fixed typo: was missing the closing `>`)
                    ["<C-Space>"] = cmp.mapping.complete(),
                    -- close completion window
                    ["<C-e>"] = cmp.mapping.abort(),
                    -- confirm completion, only when you explicitly selected an option
                    ["<CR>"] = cmp.mapping.confirm({ select = false }),
                    -- Tab / Shift-Tab: navigate the menu, or jump through snippet placeholders
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_locally_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.locally_jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),
                -- Where and how should cmp rank and find completions
                -- Order matters, cmp will provide lsp suggestions above all else
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'nvim_lsp_signature_help' },
                    { name = 'luasnip' },
                    { name = 'buffer' },
                    { name = 'path' }
                })
            })

            -- Command-line completion: type ":" and get an autocomplete menu of
            -- commands, then their arguments / file paths (LazyVim-like).
            cmp.setup.cmdline(":", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = "path" },
                }, {
                    { name = "cmdline" },
                }),
            })

            -- Completion in "/" and "?" search, from words in the buffer.
            cmp.setup.cmdline({ "/", "?" }, {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = "buffer" },
                },
            })
        end
    }
}
