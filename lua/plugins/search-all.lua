return {
  "folke/snacks.nvim",
  opts = {
    picker = {},
  },
  keys = {
    {
      "<leader>sG",
      function()
        require("snacks").picker.grep({ hidden = true, ignored = true })
      end,
      desc = "Grep (all files, incl. ignored)",
    },
    {
      "<leader>fA",
      function()
        require("snacks").picker.files({ hidden = true, ignored = true })
      end,
      desc = "Find files (all, incl. ignored)",
    },
  },
}    
