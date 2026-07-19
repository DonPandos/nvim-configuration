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

            telescope.setup({
                defaults = {
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
