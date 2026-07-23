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
            view = {
                -- Fixed width the tree always returns to. Change this number
                -- to your preferred width.
                width = 35,
                -- Don't run `:wincmd =` when a file opens, so opening a file
                -- no longer resets the tree width / re-equalizes your splits.
                preserve_window_proportions = true,
            },
            -- IntelliJ-style git status: no git glyphs in the tree, instead the
            -- file NAME is tinted by its git state (green=added, blue=modified,
            -- ...). Colors are defined below via the NvimTreeGitFile*HL groups.
            renderer = {
                highlight_git = "name", -- tint the filename, not an icon column
                icons = {
                    show = {
                        git = false,    -- drop the git status glyphs entirely
                    },
                },
            },
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

        -- IntelliJ-like colors for the git-tinted file names (see renderer.
        -- highlight_git above). These NvimTreeGitFile*HL groups are what
        -- nvim-tree applies to a name based on its git status; the folder
        -- variants link to these, so changed folders get tinted too.
        -- Re-applied on :colorscheme change so it always sticks (same pattern
        -- as lua/plugins/colorscheme.lua).
        local function set_git_name_colors()
            local hl = vim.api.nvim_set_hl
            -- added / staged to VCS (`A `) -> green
            hl(0, "NvimTreeGitFileStagedHL", { fg = "#59a869" })
            -- NOT tracked yet: untracked (`??`) / intent-to-add (` A`) -> red
            hl(0, "NvimTreeGitFileNewHL", { fg = "#c75450" })
            -- modified (` M`, `MM`) and renamed -> blue
            hl(0, "NvimTreeGitFileDirtyHL", { fg = "#6897bb" })
            hl(0, "NvimTreeGitFileRenamedHL", { fg = "#6897bb" })
            -- deleted -> gray + strikethrough (IntelliJ style)
            hl(0, "NvimTreeGitFileDeletedHL", { fg = "#6c6c6c", strikethrough = true })
            -- unmerged / conflict -> red
            hl(0, "NvimTreeGitFileMergeHL", { fg = "#c75450" })
            -- ignored -> dim
            hl(0, "NvimTreeGitFileIgnoredHL", { fg = "#545454" })
        end
        set_git_name_colors()
        vim.api.nvim_create_autocmd("ColorScheme", {
            group = vim.api.nvim_create_augroup("NvimTreeGitNameColors", { clear = true }),
            callback = set_git_name_colors,
        })

        -- Persist manual tree resizes.
        -- nvim-tree only remembers a width that was set through its own
        -- resize() (view.lua sets view_state.Active.width only when given a
        -- size). A hand-drag changes the window but NOT that tracked width, so
        -- the next file-open calls M.resize() and snaps the tree back to
        -- view.width. This records the dragged width back into nvim-tree via
        -- api.tree.resize({ width }) (which persists it), so opening a file
        -- keeps whatever width you dragged to.
        local persisting = false
        vim.api.nvim_create_autocmd("WinResized", {
            group = vim.api.nvim_create_augroup("NvimTreePersistWidth", { clear = true }),
            callback = function()
                if persisting then return end
                local api = require("nvim-tree.api")
                local winid = api.tree.winid()
                if not winid or not vim.api.nvim_win_is_valid(winid) then return end
                -- only act when the tree window itself was the one resized
                if not vim.tbl_contains(vim.v.event.windows or {}, winid) then return end
                persisting = true
                local ok = pcall(function()
                    api.tree.resize({ width = vim.api.nvim_win_get_width(winid) })
                end)
                persisting = false
                if not ok then return end
            end,
        })
    end
}
