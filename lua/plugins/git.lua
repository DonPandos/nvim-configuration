return {
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local gitsigns = require("gitsigns")
            gitsigns.setup({
                -- inline "git blame" at the end of the current line (like IntelliJ)
                current_line_blame = false, -- toggled with <leader>gB
                current_line_blame_opts = { delay = 300 },
            })

            -- hunk actions
            vim.keymap.set("n", "<leader>gh", gitsigns.preview_hunk, { desc = "[G]it Preview [H]unk" })
            vim.keymap.set("n", "<leader>gs", gitsigns.stage_hunk, { desc = "[G]it [S]tage Hunk" })
            vim.keymap.set("n", "<leader>gr", gitsigns.reset_hunk, { desc = "[G]it [R]eset Hunk" })
            vim.keymap.set("n", "<leader>gu", gitsigns.undo_stage_hunk, { desc = "[G]it [U]ndo Stage Hunk" })
            vim.keymap.set("n", "<leader>gB", gitsigns.toggle_current_line_blame, { desc = "[G]it Toggle [B]lame Line" })

            -- navigate between hunks
            vim.keymap.set("n", "]h", gitsigns.next_hunk, { desc = "Next Git Hunk" })
            vim.keymap.set("n", "[h", gitsigns.prev_hunk, { desc = "Prev Git Hunk" })
        end
    },
    {
        "tpope/vim-fugitive",
        cmd = { "Git", "G" },
        keys = {
            { "<leader>gb", ":Git blame<cr>", desc = "[G]it [B]lame" },
            { "<leader>gA", ":Git add .<cr>", desc = "[G]it Add [A]ll" },
            { "<leader>ga", ":Git add %<cr>", desc = "[G]it [A]dd current file" },
            { "<leader>gc", ":Git commit<cr>", desc = "[G]it [C]ommit" },
            { "<leader>gp", ":Git push<cr>", desc = "[G]it [P]ush" },
            { "<leader>gl", ":Git pull<cr>", desc = "[G]it Pu[l]l" },
            { "<leader>gg", ":Git<cr>", desc = "[G]it Status" },
        },
    }
}
