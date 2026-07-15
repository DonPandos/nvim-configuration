-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.keymap.set("n", "<C-e>", function()
  require("telescope").extensions.recent_files.pick()
end, { desc = "IntelliJ-like Recent Files Picker" })

