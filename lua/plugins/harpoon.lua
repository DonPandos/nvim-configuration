return {
    "ThePrimeagen/harpoon",
    event = "VeryLazy",
    dependencies = {
        "nvim-lua/plenary.nvim"
    },
    config = function()
        -- Set a vim motion to <Shift>m to mark a file with harpoon
        vim.keymap.set("n", "<s-m>", "<cmd>lua require('harpoon.mark').add_file()<cr>", {desc = "Harpoon Mark File"})
        -- Open the harpoon menu. NOTE: do NOT bind this to <TAB> -- in a terminal
        -- <Tab> and <C-i> are the same keycode, so mapping <Tab> hijacks Vim's
        -- jumplist "forward" (<C-i>). Use <leader>h instead and keep <C-i> free.
        vim.keymap.set("n", "<leader>h", "<cmd>lua require('harpoon.ui').toggle_quick_menu()<cr>", {desc = "[H]arpoon Toggle Menu"})
    end
}
