-- Setup our JDTLS server any time we open up a java file
vim.cmd [[
    augroup jdtls_lsp
        autocmd!
        autocmd FileType java lua require'config.jdtls'.setup_jdtls()
    augroup end
]]

-- Neovim persists the jumplist in the shared ShaDa file (~/.local/state/nvim/
-- shada/main.shada), so a freshly launched session inherits jumps -- and the
-- files they point at -- from OTHER/previous sessions. That's why <C-o>/<C-i>
-- could jump into a file opened in a different nvim. Clearing the jumplist once
-- at startup makes each session's back/forward history its own. Everything else
-- ShaDa restores (marks, registers, command/search history) is left untouched.
vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("clear_shada_jumplist", { clear = true }),
    callback = function()
        vim.cmd("clearjumps")
    end,
})

-- Workaround for a Neovim 0.12.4 CORE bug in vim.lsp.inlay_hint. Its decoration
-- provider (runtime .../lua/vim/lsp/inlay_hint.lua, ~line 360) passes the LSP
-- hint's `position.character` straight into nvim_buf_set_extmark as a byte
-- column WITHOUT clamping it to the line length. When a server (jdtls/vtsls)
-- reports a hint past the end of a line, set_extmark raises
--   "Invalid 'col': out of range"
-- on every redraw -- which is what surfaces via noice / nvim-notify.
--
-- We wrap nvim_buf_set_extmark and clamp the column, but ONLY for the inlay-hint
-- namespace; every other extmark call (gitsigns, diagnostics, ...) is passed
-- through untouched, and Treesitter's highlighter uses the C path so it's not
-- affected at all. Named namespaces are idempotent, so this id matches the one
-- core creates. Remove this block once Neovim ships the bounds check upstream.
do
    local inlay_ns = vim.api.nvim_create_namespace("nvim.lsp.inlayhint")
    local set_extmark = vim.api.nvim_buf_set_extmark
    vim.api.nvim_buf_set_extmark = function(buffer, ns, line, col, opts)
        if ns == inlay_ns and col > 0 then
            local ok, lines = pcall(vim.api.nvim_buf_get_lines, buffer, line, line + 1, false)
            if ok and lines[1] and col > #lines[1] then
                col = #lines[1] -- pin the hint to end-of-line instead of crashing
            end
        end
        return set_extmark(buffer, ns, line, col, opts)
    end
end
