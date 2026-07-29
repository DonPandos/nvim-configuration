-- Set our leader keybinding to space
-- Anywhere you see <leader> in a keymapping specifies the space key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Remove search highlights after searching
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Remove search highlights" })

-- Exit Vim's terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- OPTIONAL: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })

-- Preview-aware <C-j>/<C-k>: when a goto-preview float is open (it opens
-- unfocused), these scroll IT without leaving your code; otherwise they move
-- window focus down/up as before. The float is located by the window var
-- goto-preview tags it with, so this needs no plugin require and costs a cheap
-- window scan only. Scrolling the float moves the float's cursor, not the main
-- one, so it never trips goto-preview's dismiss-on-move (bound to the main buf).
local function goto_preview_win()
	for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		local ok, v = pcall(vim.api.nvim_win_get_var, w, "is-goto-preview-window")
		if ok and v == 1 and vim.api.nvim_win_is_valid(w) then
			return w
		end
	end
end

-- scroll_keys is fed to `normal!` inside the float: "3\5" = 3x<C-e> (down),
-- "3\25" = 3x<C-y> (up). Falls back to `wincmd j/k` when no preview is open.
local function preview_scroll_or_focus(scroll_keys, wincmd)
	return function()
		local w = goto_preview_win()
		if w then
			vim.api.nvim_win_call(w, function()
				vim.cmd("normal! " .. scroll_keys)
			end)
		else
			vim.cmd("wincmd " .. wincmd)
		end
	end
end

vim.keymap.set("n", "<C-j>", preview_scroll_or_focus("3\5", "j"), { desc = "Scroll preview down / focus lower window" })
vim.keymap.set("n", "<C-k>", preview_scroll_or_focus("3\25", "k"), { desc = "Scroll preview up / focus upper window" })

-- Easily split windows
vim.keymap.set("n", "<leader>wv", ":vsplit<cr>", { desc = "[W]indow Split [V]ertical" })
vim.keymap.set("n", "<leader>wh", ":split<cr>", { desc = "[W]indow Split [H]orizontal" })

-- Resize the current window. These mirror the native <C-w> resize commands but
-- as leader keys that work in EVERY terminal (Apple Terminal does not deliver
-- <C-Arrow>). Repeat the key to keep resizing; step is 5 cols / 3 rows.
vim.keymap.set("n", "<leader>w>", "<cmd>vertical resize +5<cr>", { desc = "[W]indow Wider" })
vim.keymap.set("n", "<leader>w<", "<cmd>vertical resize -5<cr>", { desc = "[W]indow Narrower" })
vim.keymap.set("n", "<leader>w+", "<cmd>resize +3<cr>", { desc = "[W]indow Taller" })
vim.keymap.set("n", "<leader>w-", "<cmd>resize -3<cr>", { desc = "[W]indow Shorter" })
vim.keymap.set("n", "<leader>w=", "<C-w>=", { desc = "[W]indow Equalize sizes" })

-- Same actions on <C-Arrow> for terminals that DO send them (Ghostty, WezTerm,
-- kitty, iTerm2). These are harmless no-ops in Apple Terminal.
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -5<cr>", { desc = "Window narrower" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +5<cr>", { desc = "Window wider" })
vim.keymap.set("n", "<C-Up>", "<cmd>resize +3<cr>", { desc = "Window taller" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -3<cr>", { desc = "Window shorter" })

-- MOVE (relocate) the current window within the layout. These are aliases for
-- the native <C-w>H/J/K/L (move to the far left/bottom/top/right edge) plus
-- rotate/swap. Uppercase HJKL so they don't clash with <leader>wh/wv (splits).
vim.keymap.set("n", "<leader>wH", "<C-w>H", { desc = "[W]indow Move Left" })
vim.keymap.set("n", "<leader>wJ", "<C-w>J", { desc = "[W]indow Move Down" })
vim.keymap.set("n", "<leader>wK", "<C-w>K", { desc = "[W]indow Move Up" })
vim.keymap.set("n", "<leader>wL", "<C-w>L", { desc = "[W]indow Move Right" })
vim.keymap.set("n", "<leader>wr", "<C-w>r", { desc = "[W]indow Rotate" })
vim.keymap.set("n", "<leader>wx", "<C-w>x", { desc = "[W]indow Swap with neighbor" })

-- Stay in indent mode
vim.keymap.set("v", "<", "<gv", { desc = "Indent left in visual mode" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right in visual mode" })

-- ---------------------------------------------------------------------------
-- IdeaVim parity: mirror the custom mappings from ~/.ideavimrc so muscle
-- memory carries over between IntelliJ (IdeaVim) and Neovim.
-- ---------------------------------------------------------------------------

-- Half-page scroll, then recenter the cursor line (IdeaVim: `<C-d> <C-d>zz`).
-- Keeps your eyes anchored in the middle instead of chasing the bottom edge.
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down half page + center" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up half page + center" })

-- Next/prev search match, recenter AND open any fold the match is inside
-- (IdeaVim: `n nzzzv`). `zz` centers, `zv` unfolds so the match is visible.
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search match (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Prev search match (centered)" })

-- Jump to next/prev problem (IdeaVim: `gn`/`gp` -> GotoNext/PrevError, i.e.
-- IntelliJ's F2 which stops on errors AND warnings). `{ min = WARN }` means
-- "WARN and anything more severe" -> warnings + errors, skipping info/hints.
-- Distinct from `]d`/`[d` (ALL severities) defined on LspAttach.
-- NOTE: this overrides Vim's native (rarely used) `gn`/`gp`.
vim.keymap.set("n", "gn", function()
    vim.diagnostic.jump({ count = 1, severity = { min = vim.diagnostic.severity.WARN }, float = true })
end, { desc = "Next problem (warn/error)" })
vim.keymap.set("n", "gp", function()
    vim.diagnostic.jump({ count = -1, severity = { min = vim.diagnostic.severity.WARN }, float = true })
end, { desc = "Prev problem (warn/error)" })

-- Shift+arrows extend a selection (IdeaVim: EditorLeft/Right/Up/DownWithSelection).
-- From normal mode: drop into charwise Visual and grow the selection. In Visual
-- mode the arrows already extend, but map them explicitly for consistency.
-- (Insert-mode shift-arrows are intentionally omitted -- they don't translate
--  cleanly in Neovim; start selections from normal mode instead.)
vim.keymap.set("n", "<S-Left>", "v<Left>", { desc = "Start selection left" })
vim.keymap.set("n", "<S-Right>", "v<Right>", { desc = "Start selection right" })
vim.keymap.set("n", "<S-Up>", "v<Up>", { desc = "Start selection up" })
vim.keymap.set("n", "<S-Down>", "v<Down>", { desc = "Start selection down" })
vim.keymap.set("v", "<S-Left>", "<Left>", { desc = "Extend selection left" })
vim.keymap.set("v", "<S-Right>", "<Right>", { desc = "Extend selection right" })
vim.keymap.set("v", "<S-Up>", "<Up>", { desc = "Extend selection up" })
vim.keymap.set("v", "<S-Down>", "<Down>", { desc = "Extend selection down" })
