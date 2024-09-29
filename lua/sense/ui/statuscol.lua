local helper = require("sense.helper")
local log = require("sense.log")
local ui_utils = require("sense.ui.utils")
local utils = require("sense.utils")

local M = {}

---@param prefix string
---@param diagnostics vim.Diagnostic[]
---@return fun(wininfo: vim.fn.getwininfo.ret.item): string[], sense.UI.Highlight[]
local function gen_render(prefix, diagnostics)
    return function (wininfo)
        local closest = diagnostics[1]
        local cursor_row = vim.api.nvim_win_get_cursor(wininfo.winid)[1]
        local distance = cursor_row - (closest.lnum + 1)
        local distance_str = utils.align_right(tostring(distance), wininfo.textoff - vim.fn.strdisplaywidth(prefix) - 1)
        local line = prefix .. distance_str .. " "
        -- if vim.fn.strdisplaywidth(line) > wininfo.textoff then
        --     line = line:sub(1, wininfo.textoff - 1) .. "+"
        -- end
        local hl_group = "SenseStatusCol" .. utils.severity_to_text(closest.severity)
        local highlight = {
            line = 0,
            hl_group = hl_group,
            col_start = 0,
            col_end = -1,
        }
        return { line }, { highlight }
    end
end

---@param wininfo vim.fn.getwininfo.ret.item
---@return string[], sense.UI.Highlight[]
local function render_top(wininfo)
    local diagnostics = helper.get_diags_above(wininfo)
    if #diagnostics == 0 then
        log.debug("no idagnostics, return empty lines")
        return {}, {}
    end
    local prefix = "↑ "
    return gen_render(prefix, diagnostics)(wininfo)
end

---@param wininfo vim.fn.getwininfo.ret.item
---@return string[], sense.UI.Highlight[]
local function render_bot(wininfo)
    local diagnostics = helper.get_diags_below(wininfo)
    if #diagnostics == 0 then
        log.debug("no idagnostics, return empty lines")
        return {}, {}
    end
    local prefix = "↓ "
    return gen_render(prefix, diagnostics)(wininfo)
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
            log.debug("virtual:render")
            local lines, highlights = render_fn(wininfo)
            log.debug(lines)
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
M.bot = gen_statuscol("bot_statuscol", function (wininfo, height)
    return {
        relative = "win",
        win = wininfo.winid,
        anchor = "SW",
        row = wininfo.height,
        col = 0,
        width = wininfo.textoff,
        height = height,
    }
end, render_bot)

return M
