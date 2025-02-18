-- stylua: ignore start
local function state() return require("sense.state") end
local function ui() return require("sense.ui") end
local function log() return require("sense.log") end
-- stylua: ignore end

local M = {}

function M.setup()
    local group = vim.api.nvim_create_augroup("sense-nvim", { clear = true })

    -- HACK: This is needed to handle `:tabnew` case
    -- Because WinEnter on `:tabnew` doesn't update the current buffer.
    -- TODO: maybe make sequential autocmd for `TabNew->BufEnter` event later
    vim.api.nvim_create_autocmd("BufEnter", {
        group = group,
        callback = function(ev)
            local winid = vim.api.nvim_get_current_win()
            log().debug("Event:", ev.event, "Buf:", ev.buf, "Match:", ev.match, "winid:", winid)
            local info = vim.fn.getwininfo(winid)[1]
            ui().render(info)
        end,
    })
    vim.api.nvim_create_autocmd("DiagnosticChanged", {
        group = group,
        callback = function(ev)
            log().debug("Event:", ev.event, "Buf:", ev.buf, "Match:", ev.match)
            local diagnostics = ev.data.diagnostics
            log().debug("diagnostics:", diagnostics)
            -- cache the diagnostics to be used from WinScrolled event
            state().diag_cache[ev.buf] = diagnostics
            -- update all windows with that buffer
            local infos = vim.fn.getwininfo()
            log().debug(infos)
            vim.iter(infos)
                :filter(function(info)
                    return info.bufnr == ev.buf
                end)
                :map(ui().render)
        end,
    })
    -- PERF: don't *update* on VimResized/WinScrolled
    -- separate repositioning and state update
    vim.api.nvim_create_autocmd({ "VimResized" }, {
        group = group,
        callback = function()
            vim.iter(vim.fn.getwininfo()):map(ui().render)
        end,
    })
    -- WinScrolled: general scroll/resize events
    vim.api.nvim_create_autocmd("WinScrolled", {
        group = group,
        callback = function (ev)
            log().debug("Event:", ev.event, "Buf:", ev.buf, "Match:", ev.match)
            if not state().is_buf_tracked(ev.buf) then
                log().debug("buffer", ev.buf, "is not tracked yet. aborting UI updates")
                return
            end
            -- NOTE: redraw and update all other windows because on WinResized, other windows might
            -- be resized too
            vim.cmd.redraw()
            vim.iter(vim.fn.getwininfo()):map(ui().render)
        end
    })
    -- WinEnter: when user do `:split`
    vim.api.nvim_create_autocmd({ "WinEnter", "CursorMoved" }, {
        group = group,
        callback = function(ev)
            local winid = vim.api.nvim_get_current_win()
            log().debug("Event:", ev.event, "Buf:", ev.buf, "Match:", ev.match, "winid:", winid)
            log().debug("buffer in new window:", vim.api.nvim_win_get_buf(winid))
            -- Ignore buffers that haven't been cached yet
            if not state().is_buf_tracked(ev.buf) then
                log().debug("buffer", ev.buf, "haven't been cached yet. aborting UI updates")
                return
            end
            -- HACK: to avoid statuscolumn not calculated
            -- see https://github.com/neovim/neovim/issues/30547
            vim.cmd.redraw()
            local info = vim.fn.getwininfo(winid)[1]
            ui().render(info)
        end,
    })
end

return M
