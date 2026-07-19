-- noice.nvim -- replaces the message/cmdline/popupmenu UI with a modern one:
-- a centered command palette, nicer LSP hover/signature, routed messages.
return {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
        "MunifTanjim/nui.nvim",
        "rcarriga/nvim-notify",
    },
    opts = {
        lsp = {
            -- Use Treesitter/markdown rendering for hover & signature docs
            override = {
                ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                ["vim.lsp.util.stylize_markdown"] = true,
                ["cmp.entry.get_documentation"] = true,
            },
            -- fidget.nvim already shows LSP progress (jdtls indexing), so keep
            -- noice's progress off to avoid a duplicate indicator.
            progress = { enabled = false },
            hover = { enabled = true },
            signature = { enabled = true },
        },
        presets = {
            bottom_search = true,        -- classic bottom "/" search
            command_palette = true,      -- centered cmdline + popupmenu (LazyVim look)
            long_message_to_split = true, -- long :messages open in a split
            inc_rename = false,
            lsp_doc_border = true,       -- bordered hover/signature docs
        },
    },
    keys = {
        { "<leader>nl", function() require("noice").cmd("last") end, desc = "[N]oice [L]ast message" },
        { "<leader>nh", function() require("noice").cmd("history") end, desc = "[N]oice [H]istory" },
        { "<leader>nd", function() require("noice").cmd("dismiss") end, desc = "[N]oice [D]ismiss" },
    },
}
