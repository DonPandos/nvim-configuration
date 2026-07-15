return {
  "mfussenegger/nvim-dap",
  optional = true,
  config = function()
    local vscode = require("dap.ext.vscode")
    local type_to_ft = { java = { "java" } }

    -- load every .vscode/launch.json under the project root
    local function load_all()
      require("dap").configurations.java = {}
      local files = vim.fn.globpath(vim.fn.getcwd(), "**/.vscode/launch.json", true, true)
      for _, path in ipairs(files) do
        vscode.load_launchjs(path, type_to_ft)
      end
    end

    -- run once on startup
    load_all()

    -- command to reload after adding/editing configs
    vim.api.nvim_create_user_command("DapReloadConfigs", function()
      load_all()
      vim.notify("Reloaded DAP configs")
    end, {})
  end,
}
