return {
    -- Editor tabs across the top, like IntelliJ's open-file tabs.
    {
        "akinsho/bufferline.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        event = "VeryLazy",
        opts = {
            options = {
                mode = "buffers",
                diagnostics = "nvim_lsp",
                show_buffer_close_icons = true,
                show_close_icon = false,
                offsets = {
                    { filetype = "NvimTree", text = "Explorer", separator = true, text_align = "left" },
                },
            },
        },
        keys = {
            { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
            { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
            { "<leader>bd", "<cmd>bdelete<cr>", desc = "[B]uffer [D]elete" },
            { "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "[B]uffer [P]in" },
            { "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "[B]uffer close [O]thers" },
        },
    },

    -- Indent guides (the vertical lines IntelliJ draws per indent level).
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            indent = { char = "│" },
            scope = { enabled = true, show_start = false, show_end = false },
        },
    },

    -- LSP progress in the corner (e.g. jdtls "indexing…"), like IntelliJ's
    -- background-task indicator.
    {
        "j-hui/fidget.nvim",
        event = "LspAttach",
        opts = {},
    },

    -- Highlight and search TODO / FIXME / HACK comments (IntelliJ's TODO view).
    {
        "folke/todo-comments.nvim",
        event = { "BufReadPost", "BufNewFile" },
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = { signs = true },
        keys = {
            { "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "[F]ind [T]ODOs" },
        },
    },
}
