return {
    "nvim-tree/nvim-tree.lua",
    config = function()
        -- Fast toggle (old behaviour -- no auto-expand-to-file)
        vim.keymap.set('n', '<leader>e', "<cmd>NvimTreeToggle<CR>", { desc = "Toggle [E]xplorer" })
        -- Reveal the current file in the tree ON DEMAND only (this is the slow
        -- one, so it's a separate key you press when you actually want it)
        vim.keymap.set('n', '<leader>E', "<cmd>NvimTreeFindFile<CR>", { desc = "[E]xplorer Reveal Current File" })
        require("nvim-tree").setup({
            hijack_netrw = true,
            auto_reload_on_write = true,
            -- Make the live filter (`f`) show its prefix
            live_filter = {
                prefix = "[FILTER]: ",
                always_show_folders = false,
            },
        })
    end
}
