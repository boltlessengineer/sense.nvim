-- stylua: ignore start
local function api() return require("sense.api") end
-- stylua: ignore end

local M = {}

local group = vim.api.nvim_create_augroup("sense-nvim", { clear = true })
vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    callback = function(_ev)
        local winid = vim.api.nvim_get_current_win()
        local info = vim.fn.getwininfo(winid)[1]
        api().redraw({ wininfo = info })
    end,
})
vim.api.nvim_create_autocmd("VimResized", {
    group = group,
    callback = function(_ev)
        api().redraw()
    end,
})
vim.api.nvim_create_autocmd("WinScrolled", {
    group = group,
    callback = function(_ev)
        vim.cmd.redraw()
        api().redraw()
    end,
})
vim.api.nvim_create_autocmd({ "WinEnter", "CursorMoved" }, {
    group = group,
    callback = function(_ev)
        local winid = vim.api.nvim_get_current_win()
        -- HACK: to avoid statuscolumn not calculated
        -- see https://github.com/neovim/neovim/issues/30547
        vim.cmd.redraw()
        local info = vim.fn.getwininfo(winid)[1]
        api().redraw({ wininfo = info })
    end,
})

return M
