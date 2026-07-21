return {
    -- Trouble: a pretty, navigable list of diagnostics -- IntelliJ's "Problems".
    {
        "folke/trouble.nvim",
        cmd = "Trouble",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = { focus = true },
        keys = {
            { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (workspace)" },
            { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Diagnostics (buffer)" },
            { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols" },
            { "<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP defs/refs" },
            { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix list" },
            { "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "TODOs" },
        },
    },

    -- Aerial: a symbol outline of the current file -- IntelliJ's "Structure".
    {
        "stevearc/aerial.nvim",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },
        cmd = { "AerialToggle", "AerialOpen" },
        opts = {
            backends = { "lsp", "treesitter", "markdown" },
            layout = { default_direction = "right", min_width = 30 },
            show_guides = true,
            -- THE fix for "outline shows only class names, no methods":
            -- a Spring Boot project attaches TWO LSP servers to each Java file --
            -- jdtls (the real class structure) AND the Spring Boot language
            -- server (application.yml/.properties completion). BOTH advertise
            -- textDocument/documentSymbol, but the Spring server answers with a
            -- near-empty stub (2 symbols, no methods). Aerial queries only ONE
            -- server, chosen by lsp.priority (default 10, first match wins), and
            -- it was landing on "spring-boot". Priority -1 means "never use this
            -- client for symbols", so aerial falls through to jdtls -> full tree.
            -- (Diagnosed live: get_client was returning spring-boot; excluding it
            -- makes jdtls the provider. See aerial util.lua get_client.)
            lsp = {
                priority = {
                    ["spring-boot"] = -1,
                },
            },
            -- Show EVERY symbol kind (fields/variables too), not just the default
            -- Class/Method/... set -- the full IntelliJ "Structure" view.
            filter_kind = false,
        },
        keys = {
            -- Open the outline and force a fresh fetch from jdtls. On a cold
            -- start aerial may attach before jdtls has finished indexing and
            -- cache a partial reply; refetching on open (now that it targets
            -- jdtls, not the Spring stub) guarantees the complete structure.
            {
                "<leader>o",
                function()
                    local aerial = require("aerial")
                    local src = vim.api.nvim_get_current_buf()
                    aerial.toggle()
                    vim.schedule(function()
                        pcall(aerial.refetch_symbols, src)
                    end)
                end,
                desc = "Structure (Aerial)",
            },
        },
    },

    -- Breadcrumbs at the top of the window (IntelliJ's navigation bar).
    -- barbecue drives nvim-navic, which attaches to any LSP with documentSymbol.
    {
        "utilyre/barbecue.nvim",
        name = "barbecue",
        version = "*",
        event = "VeryLazy",
        dependencies = {
            "SmiteshP/nvim-navic",
            "nvim-tree/nvim-web-devicons",
        },
        opts = {
            attach_navic = true, -- let barbecue manage navic attachment
            show_dirname = false,
            show_basename = true,
        },
    },
}
