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
            -- hjkl-style navigation: l opens/expands, h closes.
            on_attach = function(bufnr)
                local api = require("nvim-tree.api")
                local function opts(desc)
                    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
                end

                -- Keep ALL of nvim-tree's default mappings (<CR>, o, a, d, r, ...)
                api.config.mappings.default_on_attach(bufnr)

                -- l: expand a closed folder, or open a file. Deliberately does
                -- NOT collapse an already-open folder -- that's h's job -- so l
                -- always means "go in / open", never "toggle".
                vim.keymap.set("n", "l", function()
                    local node = api.tree.get_node_under_cursor()
                    if node.nodes ~= nil then    -- directory (has children list)
                        if not node.open then
                            api.node.open.edit() -- expand it
                        end
                    else
                        api.node.open.edit()     -- file -> open in editor
                    end
                end, opts("Open / expand"))

                -- h: if the cursor is on an OPEN folder, collapse it; otherwise
                -- close the parent folder and move the cursor up onto it -- i.e.
                -- "close the folder I'm in".
                vim.keymap.set("n", "h", function()
                    local node = api.tree.get_node_under_cursor()
                    if node.nodes ~= nil and node.open then
                        api.node.open.edit()             -- collapse this open folder
                    else
                        api.node.navigate.parent_close() -- close parent, jump to it
                    end
                end, opts("Close folder / parent"))
            end,
        })
    end
}
