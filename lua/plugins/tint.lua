-- tint.nvim -- gently DIM the inactive windows so the one your cursor is in
-- stands out (replaces the colored border from colorful-winsep). We tried tint
-- before with its default tint = -40, which darkened the syntax colors so much
-- that text got hard to read ("dark fields"). This config is deliberately
-- subtle: half the dim, and most of the color saturation preserved, so an
-- inactive window looks a touch darker but stays perfectly legible.
return {
	"levouh/tint.nvim",
	event = "VeryLazy", -- set up its WinEnter/WinLeave hooks after startup
	opts = {
		-- How much to darken (negative dims). -40 was too strong; -18 is "a bit".
		-- Nudge toward 0 for subtler, toward -40 for stronger.
		tint = -5,
		-- Fraction of color saturation to KEEP (1.0 = full color). High so the
		-- dimmed window keeps its syntax colors instead of washing out to grey.
		saturation = 0.85,
		-- Also darken the window BACKGROUND, not just the text -- this is what
		-- makes the whole inactive pane read as "slightly darker" rather than
		-- just muted text.
		tint_background_colors = true,
		-- Keep these crisp so the active window is easy to pick out: window
		-- separators and the status line shouldn't be dimmed.
		highlight_ignore_patterns = { "WinSeparator", "Status.*", "VertSplit" },
		-- Never dim floating windows (Telescope, which-key, notifications) --
		-- dimming a popup that isn't "the active window" looks wrong.
		window_ignore_function = function(winid)
			local ok, cfg = pcall(vim.api.nvim_win_get_config, winid)
			if ok and cfg.relative and cfg.relative ~= "" then
				return true -- floating window -> leave it alone
			end
			return false
		end,
	},
}
