-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Load every .vscode/launch.json under the project root into nvim-dap
local function load_launch_configs()
  local dap = require("dap")
  dap.configurations.java = {}
  local vscode = require("dap.ext.vscode")
  local files = vim.fn.globpath(vim.fn.getcwd(), "**/.vscode/launch.json", true, true)
  for _, path in ipairs(files) do
    vscode.load_launchjs(path, { java = { "java" } })
  end
  vim.notify("Loaded " .. #files .. " launch.json file(s)")
end

vim.api.nvim_create_user_command("DapReloadConfigs", load_launch_configs, {})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  once = true,
  callback = function()
    vim.defer_fn(load_launch_configs, 1000)
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
  end,
})
