return {
  -- Keep blink.cmp's inline "ghost text" preview ENABLED (LazyVim turns it on via
  -- vim.g.ai_cmp), but work around an upstream bug: ghost_text.draw_preview() feeds
  -- the completion item's LSP textEdit end-column straight to nvim_buf_set_extmark
  -- without clamping it to the current line length. Some servers -- notably the
  -- Spring Boot LS -- return ranges whose end column sits past the end of the line,
  -- which throws "Invalid 'col': out of range" on every CursorMovedI.
  --
  -- Fix: temporarily clamp the extmark column to the line's byte length for the
  -- duration of draw_preview, so the preview still renders (at end-of-line for the
  -- overshooting items) instead of erroring. pcall is a belt-and-suspenders guard.
  -- Remove this once blink ships a fix (tracked: ghost_text col clamping).
  "saghen/blink.cmp",
  init = function()
    LazyVim.on_load("blink.cmp", function()
      local ghost = require("blink.cmp.completion.windows.ghost_text")
      local original_draw = ghost.draw_preview
      ghost.draw_preview = function(...)
        local real_set_extmark = vim.api.nvim_buf_set_extmark
        vim.api.nvim_buf_set_extmark = function(buffer, ns, row, col, opts)
          local line = vim.api.nvim_buf_get_lines(buffer, row, row + 1, false)[1]
          if line and col > #line then
            col = #line
          end
          return real_set_extmark(buffer, ns, row, col, opts)
        end
        local ok = pcall(original_draw, ...)
        vim.api.nvim_buf_set_extmark = real_set_extmark
        return ok
      end
    end)
  end,
}
