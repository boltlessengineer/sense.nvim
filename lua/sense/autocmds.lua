-- stylua: ignore start
local function state() return require("sense.state") end
local function ui() return require("sense.ui") end
local function log() return require("sense.log") end
-- stylua: ignore end

local M = {}

function M.setup()
    local group = vim.api.nvim_create_augroup("sense-nvim", { clear = true })

    vim.api.nvim_create_autocmd("DiagnosticChanged", {
        group = group,
        callback = function(ev)
            log().debug("Event:".. ev.event.. "Buf:".. ev.buf.. "Match:".. ev.match)
            local diagnostics = ev.data.diagnostics
            -- cache the diagnostics to be used from WinScrolled event
            state().diag_cache[ev.buf] = diagnostics
            -- update all windows with that buffer
            local infos = vim.fn.getwininfo()
            vim.iter(infos)
                :filter(function(info)
                    return info.bufnr == ev.buf
                end)
                :map(ui().update)
        end,
    })
    -- PERF: don't *update* on VimResized/WinScrolled
    -- separate repositioning and state update
    vim.api.nvim_create_autocmd({ "VimResized" }, {
        group = group,
        callback = function()
            local infos = vim.fn.getwininfo()
            vim.iter(infos):map(ui().update)
        end,
    })
    -- WinEnter: when user do `:split`
    -- WinScrolled: general scroll/resize events
    vim.api.nvim_create_autocmd("WinScrolled", {
        group = group,
        callback = function (ev)
            log().debug("Event:".. ev.event.. "Buf:".. ev.buf.. "Match:".. ev.match, "")
            if not state().diag_cache[ev.buf] then
                log().debug("buffer", ev.buf, "haven't been cached yet. aborting UI updates")
                return
            end
            local winid = tonumber(ev.match)
            ---@cast winid number
            if vim.api.nvim_win_is_valid(winid) then
                local info = vim.fn.getwininfo(winid)[1]
                ui().update(info)
            end
        end
    })
    vim.api.nvim_create_autocmd({ "WinEnter", "CursorMoved" }, {
        group = group,
        callback = function(ev)
            log().debug("Event:".. ev.event.. "Buf:".. ev.buf.. "Match:".. ev.match, "")
            -- Ignore buffers that haven't been cached yet
            if not state().diag_cache[ev.buf] then
                log().debug("buffer", ev.buf, "haven't been cached yet. aborting UI updates")
                return
            end
            local winid
            if ev.event == "WinScrolled" then
                winid = tonumber(ev.match)
            else
                winid = vim.api.nvim_get_current_win()
            end
            -- HACK: to avoid statuscolumn not calculated
            -- see https://github.com/neovim/neovim/issues/30547
            vim.cmd.redraw()
            local info = vim.fn.getwininfo(winid)[1]
            ui().update(info)
        end,
    })
end

return M
