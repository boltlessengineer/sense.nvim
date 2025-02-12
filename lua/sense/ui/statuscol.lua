local config = require("sense.config")
local helper = require("sense.helper")
local log = require("sense.log")
local uiutils = require("sense.utils.uiutils")
local utils = require("sense.utils")

local M = {}

---@param prefix string
---@param diagnostics vim.Diagnostic[]
---@param wininfo vim.fn.getwininfo.ret.item
---@return string[]
---@return sense.UI.Highlight[]
local function gen_render(prefix, diagnostics, wininfo)
    local closest = diagnostics[1]
    local cursor_row = vim.api.nvim_win_get_cursor(wininfo.winid)[1]
    local distance = math.abs(cursor_row - (closest.lnum + 1))
    local distance_str =
        utils.align_right(tostring(distance), wininfo.textoff - vim.fn.strdisplaywidth(prefix) - 1)
    local line = prefix .. distance_str .. " "
    local hl_group = "SenseStatusCol" .. utils.severity_to_text(closest.severity)
    local highlight = {
        line = 0,
        hl_group = hl_group,
        col_start = 0,
        col_end = -1,
    }
    return { line }, { highlight }
end

---@param wininfo vim.fn.getwininfo.ret.item
---@return string[], sense.UI.Highlight[]
function M.render_top(wininfo)
    local diagnostics = helper.get_diags_above(wininfo)
    if #diagnostics == 0 then
        log.debug("no idagnostics, return empty lines")
        return {}, {}
    end
    local prefix = "↑ "
    return gen_render(prefix, diagnostics, wininfo)
end

---@param wininfo vim.fn.getwininfo.ret.item
---@return string[], sense.UI.Highlight[]
function M.render_bot(wininfo)
    local diagnostics = helper.get_diags_below(wininfo)
    if #diagnostics == 0 then
        log.debug("no idagnostics, return empty lines")
        return {}, {}
    end
    local prefix = "↓ "
    return gen_render(prefix, diagnostics, wininfo)
end

---@param calc_pos fun(wininfo: vim.fn.getwininfo.ret.item, height: number): vim.api.keyset.win_config
---@param render_fn fun(wininfo: vim.fn.getwininfo.ret.item): string[], sense.UI.Highlight[]
---@return sense.UI.Indicator
local function gen_statuscol_ui(name, calc_pos, render_fn)
    local var_name = "__sense_nvim_" .. name
    ---@type sense.UI.Indicator
    return {
        name = name,
        ---@param wininfo vim.fn.getwininfo.ret.item
        close = function(_self, wininfo)
            log.debug("statuscolumn:close")
            local win = vim.w[wininfo.winid][var_name]
            vim.w[wininfo.winid][var_name] = nil
            if win and vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_win_close(win, true)
            end
        end,
        ---@param wininfo vim.fn.getwininfo.ret.item
        render = function(self, wininfo)
            log.debug("statuscolumn:render")
            local lines, highlights = render_fn(wininfo)
            log.debug("lines", lines)
            if #lines == 0 then
                self:close(wininfo)
                return
            end
            local _win, buf = (function ()
                local win = vim.w[wininfo.winid][var_name]
                local win_pos = calc_pos(wininfo, #lines)
                local buf
                if win and vim.api.nvim_win_is_valid(win) then
                    vim.api.nvim_win_set_config(win, win_pos)
                    buf = vim.api.nvim_win_get_buf(win)
                else
                    win, buf = uiutils.open_win_buf(win_pos)
                    if win == 0 then
                        return win, buf
                    end
                    vim.w[wininfo.winid][var_name] = win
                end
                return win, buf
            end)()

            uiutils.set_lines(buf, lines, highlights)
        end,
    }
end

---@package
M.top = gen_statuscol_ui("top_statuscol", function(wininfo, height)
    return {
        relative = "win",
        win = wininfo.winid,
        anchor = "NW",
        row = 0,
        col = 0,
        width = wininfo.textoff,
        height = height,
    }
end, config.indicators.statuscolumn.render_top or M.render_top)
---@package
M.bot = gen_statuscol_ui("bot_statuscol", function(wininfo, height)
    return {
        relative = "win",
        win = wininfo.winid,
        anchor = "SW",
        row = wininfo.height,
        col = 0,
        width = wininfo.textoff,
        height = height,
    }
end, config.indicators.statuscolumn.render_bot or M.render_bot)

return M
