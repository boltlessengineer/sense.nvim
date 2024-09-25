local helper = require("sense.helper")
local ui_utils = require("sense.ui.utils")
local utils = require("sense.utils")

local M = {}

---@param wininfo vim.fn.getwininfo.ret.item
---@return string[], sense.UI.Highlight[]
local function render_top(wininfo)
    local diagnostics = helper.get_diags_above(wininfo)
    if #diagnostics == 0 then
        return {}, {}
    end
    local closest = diagnostics[1]
    local cursor_row = vim.api.nvim_win_get_cursor(wininfo.winid)[1]
    local prefix = "↑ "
    local distance = cursor_row - (closest.lnum + 1)
    local distance_str = utils.align_right(tostring(distance), wininfo.textoff - vim.fn.strdisplaywidth(prefix) - 1)
    local line = prefix .. distance_str .. " "
    if vim.fn.strdisplaywidth(line) > wininfo.textoff then
        line = line:sub(1, wininfo.textoff - 1) .. "+"
    end
    local highlight = {
        line = 0,
        hl_group = "DiagnosticVirtualTextError",
        col_start = 0,
        col_end = -1,
    }
    return { line }, { highlight }
end

---@param calc_pos fun(wininfo: vim.fn.getwininfo.ret.item, height: number): vim.api.keyset.win_config
---@param render_fn fun(wininfo: vim.fn.getwininfo.ret.item): string[], sense.UI.Highlight[]
---@return sense.UI.Component
local function gen_statuscol(name, calc_pos, render_fn)
    local var_name = "__sense_nvim_" .. name
    local function open(wininfo, height)
        local win = vim.w[wininfo.winid][var_name]
        local win_pos = calc_pos(wininfo, height)
        local buf
        if win and vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_set_config(win, win_pos)
            buf = vim.api.nvim_win_get_buf(win)
        else
            win, buf = ui_utils.open_win_buf(win_pos)
            if win == 0 then
                return win, buf
            end
            vim.w[wininfo.winid][var_name] = win
        end
        return win, buf
    end
    return {
        ---@param wininfo vim.fn.getwininfo.ret.item
        close = function(_self, wininfo)
            local win = vim.w[wininfo.winid][var_name]
            vim.w[wininfo.winid][var_name] = nil
            if win and vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_win_close(win, true)
            end
        end,
        ---@param wininfo vim.fn.getwininfo.ret.item
        render = function(self, wininfo)
            local lines, highlights = render_fn(wininfo)
            if #lines == 0 then
                self:close(wininfo)
                return
            end
            local _win, buf = open(wininfo, #lines)

            ui_utils.set_lines(buf, lines, highlights)
        end,
    }
end

-- FIXME: don't render anything when textoff is 0
M.top = gen_statuscol("top_statuscol", function (wininfo, height)
    return {
        relative = "win",
        win = wininfo.winid,
        anchor = "NW",
        row = 0,
        col = 0,
        width = wininfo.textoff,
        height = height,
    }
end, render_top)

return M
