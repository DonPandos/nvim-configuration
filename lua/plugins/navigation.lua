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
        },
        keys = {
            { "<leader>o", "<cmd>AerialToggle!<cr>", desc = "Structure (Aerial)" },
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
