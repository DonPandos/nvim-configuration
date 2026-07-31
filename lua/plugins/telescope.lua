return {
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.8',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'nvim-telescope/telescope-ui-select.nvim',
        },
        config = function()
            local telescope = require("telescope")
            local actions = require("telescope.actions")
            local builtin = require('telescope.builtin')

            -- ---------------------------------------------------------------
            -- IntelliJ-style grep rows: the matched CODE sits on the left and
            -- the dimmed "file.java:line" is pushed FLUSH-RIGHT (instead of a
            -- long path prefixed before the code, which wastes width and hides
            -- the match). The full path still shows in the preview on the right.
            --
            -- How the right-align works: `entry_display` lays out two columns.
            -- The text column is given a *function* width = (results width - loc
            -- length - 2), so it fills everything except the room the location
            -- needs; the second column (`remaining`) then lands flush-right. We
            -- rebuild the displayer per row so the reserved width matches THIS
            -- row's location length.
            -- ---------------------------------------------------------------
            local entry_display = require("telescope.pickers.entry_display")
            local make_entry = require("telescope.make_entry")
            local tsutils = require("telescope.utils")
            local grep_parse = make_entry.gen_from_vimgrep({}) -- parses file:lnum:col:text

            local function ivy_grep_entry_maker(line)
                local entry = grep_parse(line)
                if entry == nil then
                    return nil
                end
                entry.display = function(e)
                    local text = (e.text or ""):gsub("^%s+", "") -- drop leading indentation
                    local loc = string.format("%s:%s", tsutils.path_tail(e.filename), e.lnum)
                    local displayer = entry_display.create({
                        separator = " ",
                        items = {
                            { width = function(_, cols) return math.max(1, cols - #loc - 2) end },
                            { remaining = true },
                        },
                    })
                    return displayer({
                        { text },
                        { loc, "Comment" }, -- dimmed, like IntelliJ's right-hand file column
                    })
                end
                return entry
            end

            telescope.setup({
                defaults = {
                    -- Show the FILENAME first (always visible), then the parent
                    -- directory after it -- instead of a long path that pushes the
                    -- class name off the right edge. Matters in a multi-module repo:
                    -- two `OrderService.java` in different modules stay distinct.
                    --
                    -- NOTE: telescope 0.1.8 has no built-in "filename_first" (added
                    -- upstream after this tag), so we replicate it with a function.
                    -- find_files' row keeps only the string here (make_entry.lua),
                    -- so the dir can't be dimmed on 0.1.8 -- unpin telescope for the
                    -- native, dimmed filename_first. Applies to find_files, buffers,
                    -- oldfiles and the LSP location pickers (live_grep/grep_string
                    -- use their own entry_maker below, so they're unaffected).
                    path_display = function(_, path)
                        local tail = require("telescope.utils").path_tail(path)
                        local dir = vim.fn.fnamemodify(path, ":h")
                        if dir == "." or dir == "" then
                            return tail
                        end
                        return string.format("%s  %s", tail, dir)
                    end,
                    -- keymappings to navigate inside the telescope prompt
                    mappings = {
                        i = {
                            ["<C-n>"] = actions.cycle_history_next,
                            ["<C-p>"] = actions.cycle_history_prev,
                            ["<C-j>"] = actions.move_selection_next,
                            ["<C-k>"] = actions.move_selection_previous,
                        },
                    },
                },
                -- Per-picker tweaks. For the LSP "location" lists (references /
                -- implementations / definitions), drop the source-code text from
                -- each row (`show_line = false`) -- you already see the code in the
                -- preview on the right, so the Results column is just filenames.
                pickers = {
                    lsp_references = { show_line = false },
                    lsp_implementations = { show_line = false },
                    lsp_definitions = { show_line = false },
                    lsp_type_definitions = { show_line = false },
                    -- IntelliJ-style rows for grep (code left, file:line right)
                    live_grep = { entry_maker = ivy_grep_entry_maker },
                    grep_string = { entry_maker = ivy_grep_entry_maker },
                },
                extensions = {
                    -- use ui-select dropdown for things like code actions
                    ["ui-select"] = {
                        require("telescope.themes").get_dropdown({}),
                    },
                },
            })

            -- load AFTER setup (this was previously nested inside the setup
            -- table, so it ran at the wrong time)
            telescope.load_extension("ui-select")

            vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "[F]ind [F]iles" })
            vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = "[F]ind by [G]rep" })
            vim.keymap.set('n', '<leader>fd', builtin.diagnostics, { desc = '[F]ind [D]iagnostics' })
            vim.keymap.set('n', '<leader>fr', builtin.resume, { desc = '[F]inder [R]esume' })
            vim.keymap.set('n', '<leader>f.', builtin.oldfiles, { desc = '[F]ind Recent Files ("." for repeat)' })
            vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = '[F]ind Existing [B]uffers' })
            vim.keymap.set('n', '<leader>fs', builtin.lsp_dynamic_workspace_symbols, { desc = '[F]ind [S]ymbols (workspace)' })
            vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = '[F]ind [K]eymaps' })
        end
    },
}
