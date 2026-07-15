return {
  "mfussenegger/nvim-dap",
  optional = true,
  config = function()
    vim.fn.sign_define("DapBreakpoint", {
      text = "●",
      texthl = "DiagnosticError",   -- red
      linehl = "",
      numhl = "",
    })
    vim.fn.sign_define("DapBreakpointCondition", {
      text = "◆",
      texthl = "DiagnosticWarn",
    })
    vim.fn.sign_define("DapStopped", {
      text = "▶",
      texthl = "DiagnosticInfo",
      linehl = "Visual",            -- highlights the whole current line
      numhl = "",
    })
    vim.fn.sign_define("DapBreakpointRejected", {
      text = "✗",
      texthl = "DiagnosticError",
    })
  end,
}
