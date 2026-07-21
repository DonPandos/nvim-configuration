-- colorful-winsep.nvim -- draws a COLORED BORDER around the active window (the
-- one the cursor is in), instead of dimming the others like tint did. Only
-- draws when there's more than one window, so a single window stays clean.
-- A solid colored line renders well even on Apple Terminal (no color-blending
-- needed, unlike tint's dimming).
return {
    "nvim-zh/colorful-winsep.nvim",
    event = { "WinLeave" }, -- loads once you first split/leave a window
    opts = {
        -- Border style around the active window:
        --   "bold" (thick), "single", "rounded" (curved corners), "double".
        border = "bold",
        -- Border colour (foreground). #61afef = a clear blue accent (matches the
        -- DapLogPoint blue you already use). Change to any hex you like.
        highlight = "#61afef",
        -- Don't draw the border for these UI/sidebar filetypes.
        excluded_ft = {
            "packer", "TelescopePrompt", "mason",
            "NvimTree", "aerial", "trouble", "neo-tree", "help", "qf",
        },
    },
}
