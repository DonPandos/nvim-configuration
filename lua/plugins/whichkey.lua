return {
    'folke/which-key.nvim',
    event = 'VimEnter',
    config = function()
        local which_key = require('which-key')

        -- which-key v3: setup then register groups with add() (register() is deprecated)
        which_key.setup()

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
            { "<leader>w", group = "[W]indow" },
            { "<leader>x", group = "Diagnostics/Trouble" },
        })
    end
}
