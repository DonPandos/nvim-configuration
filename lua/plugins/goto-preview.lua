-- goto-preview -- IntelliJ "Quick Definition" (Cmd+Y) for Neovim.
--
-- Peek a symbol's definition in a floating window WITHOUT leaving the current
-- buffer. Main use: cursor on an enum-typed field, hit <leader>cp to glance at
-- the enum's constants, then just move the cursor and the float vanishes.
--
--   <leader>cp  preview definition of the symbol under the cursor
--               (put the cursor on the enum TYPE name, e.g. `Status` in
--                `private Status status;`)
--   <leader>ct  preview the TYPE definition of the symbol under the cursor
--               (put the cursor on the field NAME `status` -> peeks `Status`)
--   <leader>cP  close any open preview floats (fallback; they also auto-close
--               on cursor move)

-- Size the preview to ~90% of the window it opens in, recomputed on every call
-- (goto-preview forwards per-call opts.width/height straight to nvim_open_win),
-- so it tracks the current editor size and stays near-fullscreen after resizes.
local function preview_opts()
    return {
        width = math.floor(vim.api.nvim_win_get_width(0) * 0.9),
        height = math.floor(vim.api.nvim_win_get_height(0) * 0.9),
    }
end

return {
    "rmagatti/goto-preview",
    keys = {
        {
            "<leader>cp",
            function() require("goto-preview").goto_preview_definition(preview_opts()) end,
            desc = "[C]ode [P]review Definition",
        },
        {
            "<leader>ct",
            function() require("goto-preview").goto_preview_type_definition(preview_opts()) end,
            desc = "[C]ode Preview [T]ype Definition",
        },
        {
            "<leader>cP",
            function() require("goto-preview").close_all_win() end,
            desc = "[C]ode Close [P]reviews",
        },
    },
    opts = {
        default_mappings = false, -- we define our own under <leader>c
        -- Peek UX: keep the cursor in the code, and dismiss the float as soon
        -- as you move -- a true "glance and go". For a long class you can't
        -- scroll this way; flip focus_on_open = true / dismiss_on_move = false
        -- if you'd rather step into the (now large) float and scroll it.
        focus_on_open = false,
        dismiss_on_move = true,
    },
}
