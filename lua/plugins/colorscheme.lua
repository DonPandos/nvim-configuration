return {
    "nickkadutskyi/jb.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
    config = function()
        -- require("jb").setup({transparent = true})
        vim.cmd("colorscheme jb")

        -- Force high-contrast line numbers. jb's default LineNr is a very subtle
        -- gray that disappears on terminals which fake truecolor (e.g. Apple
        -- Terminal). Re-applied on any :colorscheme change so it always sticks.
        local function fix_gutter()
            vim.api.nvim_set_hl(0, "LineNr", { fg = "#8a90a0" })
            vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#6b7280" })
            vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#6b7280" })
            vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#e5c07b", bold = true })
        end
        fix_gutter()
        vim.api.nvim_create_autocmd("ColorScheme", { callback = fix_gutter })
    end,
}
