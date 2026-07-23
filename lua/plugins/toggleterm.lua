-- toggleterm.nvim -- IntelliJ-like toggle terminal(s).
--
-- <C-\>            toggle the last terminal open/closed (like IntelliJ Alt+F12)
-- <leader>tf/th/tv open a Float / Horizontal / Vertical terminal
-- A count addresses a numbered terminal, e.g. 2<C-\> toggles terminal #2,
-- so you can keep several independent shells side by side.
--
-- Exiting terminal mode is still <Esc><Esc> (mapped globally in
-- lua/config/keymaps.lua); <C-hjkl> below jump between windows without it.
return {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
        -- Bare lhs = lazy-load trigger only; the real <C-\> mapping is created
        -- by `open_mapping` in setup() once the plugin loads.
        { [[<C-\>]], mode = { "n", "t" }, desc = "Toggle terminal" },
        { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "[T]erminal [F]loat" },
        { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "[T]erminal [H]orizontal" },
        { "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", desc = "[T]erminal [V]ertical" },
    },
    config = function()
        require("toggleterm").setup({
            open_mapping = [[<C-\>]],
            direction = "horizontal", -- default shape for a bare <C-\>
            float_opts = {
                border = "curved",
            },
            -- Split sizes: 15 rows for a horizontal split, 40% of columns for a
            -- vertical one.
            size = function(term)
                if term.direction == "horizontal" then
                    return 15
                elseif term.direction == "vertical" then
                    return math.floor(vim.o.columns * 0.4)
                end
            end,
            start_in_insert = true, -- drop straight into the shell, ready to type
            persist_size = true,
            persist_mode = true, -- reopen in the mode you left it in
            shade_terminals = true, -- slightly darken the terminal window
        })

        -- Inside a toggleterm buffer, let <C-hjkl> move between windows straight
        -- from terminal mode (no <Esc><Esc> first). Buffer-local so it never
        -- leaks into other terminals (e.g. the Spring Boot run terminal).
        vim.api.nvim_create_autocmd("TermOpen", {
            pattern = "term://*toggleterm#*",
            callback = function()
                local o = { buffer = 0, silent = true }
                vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], o)
                vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], o)
                vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], o)
                vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], o)
            end,
        })
    end,
}
