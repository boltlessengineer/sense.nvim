-- TODO: lazy-load these
local state = require("sense.state")
local ui = require("sense.ui")
local log = require("sense.log")

local M = {}

function M.setup()
    local group = vim.api.nvim_create_augroup("sense-nvim", { clear = true })

    vim.api.nvim_create_autocmd("DiagnosticChanged", {
        group = group,
        callback = function(ev)
            log.debug("Event:", ev.event, "Buf:", ev.buf, "Match:", ev.match)
            local diagnostics = ev.data.diagnostics
            -- cache the diagnostics to be used from WinScrolled event
            state.diag_cache[ev.buf] = diagnostics
            -- update all windows with that buffer
            local infos = vim.fn.getwininfo()
            vim.iter(infos)
                :filter(function(info)
                    return info.bufnr == ev.buf
                end)
                :map(ui.update)
        end,
    })
    vim.api.nvim_create_autocmd({ "VimResized" }, {
        callback = function()
            local infos = vim.fn.getwininfo()
            vim.iter(infos):map(ui.update)
        end,
    })
    -- WinEnter: when user do `:split`
    -- WinScrolled: general scroll/resize events
    vim.api.nvim_create_autocmd({ "WinEnter", "WinScrolled", "CursorMoved" }, {
        group = group,
        callback = function(ev)
            log.debug("Event:", ev.event, "Buf:", ev.buf, "Match:", ev.match)
            -- Ignore buffers that haven't been cached yet
            if not state.diag_cache[ev.buf] then
                log.debug("buffer", ev.buf, "haven't been cached yet. aborting UI updates")
                return
            end
            local winid
            if ev.event == "WinScrolled" then
                winid = tonumber(ev.match)
            else
                winid = vim.api.nvim_get_current_win()
            end
            local info = vim.fn.getwininfo(winid)[1]
            ui.update(info)
        end,
    })
end

return M
