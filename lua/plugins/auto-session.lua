-- Per-directory session persistence.
-- Open `nvim` (no file argument) inside a folder and your previous state --
-- the same open files and window layout -- is restored. Closing nvim auto-saves
-- the session for that folder. Opening `nvim <file>` skips restore (fresh).
--
-- Start fresh: `<leader>qd` (:SessionDelete) wipes the saved session for the
-- current folder, so the next `nvim` here opens clean.
return {
    "rmagatti/auto-session",
    lazy = false,
    opts = {
        auto_save = true,    -- save the session on exit (default)
        auto_restore = true, -- restore on `nvim` in a folder with a session (default)
        -- Don't auto-save/restore sessions in these directories (too broad /
        -- not real project roots).
        suppressed_dirs = { "~/", "~/Downloads", "/" },
        -- nvim-tree doesn't survive being serialized into a session; close it
        -- before saving so restore doesn't reopen a broken explorer buffer.
        -- pcall keeps save working even if nvim-tree isn't loaded/open.
        pre_save_cmds = {
            function()
                pcall(vim.cmd, "NvimTreeClose")
            end,
        },
    },
    keys = {
        { "<leader>qr", "<cmd>SessionRestore<cr>", desc = "[Q] Restore session (this folder)" },
        { "<leader>qs", "<cmd>SessionSave<cr>",    desc = "[Q] Save session now" },
        { "<leader>qd", "<cmd>SessionDelete<cr>",  desc = "[Q] Delete session (start fresh)" },
        { "<leader>qf", "<cmd>SessionSearch<cr>",  desc = "[Q] Find / switch sessions" },
    },
}
