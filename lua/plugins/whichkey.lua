return {
    'folke/which-key.nvim',
    event = 'VimEnter',
    config = function()
        local which_key = require('which-key')

        -- which-key v3: setup then register groups with add() (register() is deprecated)
        --
        -- "helix" preset: a single-column panel pinned to the RIGHT edge.
        -- Under the hood (see which-key/presets.lua) it sets win.col = -1
        -- (negative = measured from the right edge), a narrow window width
        -- (30-60 cols) AND layout.width.min = 30, so only ONE mapping column
        -- ever fits -> a vertical single-column list on the right.
        which_key.setup({
            preset = "helix",
        })

        which_key.add({
            { "<leader>/", group = "Comments" },
            { "<leader>b", group = "[B]uffers" },
            { "<leader>c", group = "[C]ode" },
            { "<leader>d", group = "[D]ebug" },
            { "<leader>e", group = "[E]xplorer" },
            { "<leader>f", group = "[F]ind" },
            { "<leader>g", group = "[G]it" },
            { "<leader>J", group = "[J]ava" },
            { "<leader>n", group = "[N]oice" },
            { "<leader>q", group = "Session (persistence)" },
            { "<leader>w", group = "[W]indow" },
            { "<leader>x", group = "Diagnostics/Trouble" },
        })
    end
}
