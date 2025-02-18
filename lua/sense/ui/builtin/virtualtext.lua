local log = require("sense.log")
local helper = require("sense.helper")
local utils = require("sense.utils")
local uiutils = require("sense.utils.uiutils")

local M = {}

---@param wininfo vim.fn.getwininfo.ret.item
---@return string[], sense.UI.Highlight[]
function M.render_diagnostic_top(wininfo)
    local diagnostics, edge = helper.get_diags_above(wininfo)
    local closest = diagnostics[1]
    if not closest then
        log.debug("no diagnostics, return empty lines")
        return {}, {}
    end
    if edge and edge.severity <= closest.severity then
        return {}, {}
    end
    local cursor_row = vim.api.nvim_win_get_cursor(wininfo.winid)[1]
    local distance = cursor_row - (closest.lnum + 1)
    local line = (" ↑ %d lines above"):format(distance)
    local msg = vim.split(closest.message, "[\n\r]")[1]
    line = line .. " [" .. msg .. "]"
    local hl_group = "SenseVirtualText" .. utils.severity_to_text(closest.severity)
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
function M.render_diagnostic_bot(wininfo)
    local diagnostics, edge = helper.get_diags_below(wininfo)
    local closest = diagnostics[1]
    if not closest then
        log.debug("no diagnostics, return empty lines")
        return {}, {}
    end
    if edge and edge.severity <= closest.severity then
        return {}, {}
    end
    local cursor_row = vim.api.nvim_win_get_cursor(wininfo.winid)[1]
    local distance = (closest.lnum + 1) - cursor_row
    local line = (" ↓ %d lines below"):format(distance)
    local msg = vim.split(closest.message, "[\n\r]")[1]
    line = line .. " [" .. msg .. "]"
    local hl_group = "SenseVirtualText" .. utils.severity_to_text(closest.severity)
    local highlight = {
        line = 0,
        hl_group = hl_group,
        col_start = 0,
        col_end = -1,
    }
    return { line }, { highlight }
end

---@return sense.Indicator
function M.gen_virtualtext_top(render_line)
    local Top = {}
    Top.__index = Top
    function Top:new(winid)
        return setmetatable({ target_winid = winid }, self)
    end
    function Top:destroy()
        if self.winid and vim.api.nvim_win_is_valid(self.winid) then
            log.debug("close window", self.winid)
            vim.api.nvim_win_close(self.winid, true)
        end
    end
    ---@param wininfo vim.fn.getwininfo.ret.item
    function Top:render(wininfo)
        if wininfo.winid ~= self.target_winid then
            return
        end
        local lines, highlights = render_line(wininfo)
        if #lines == 0 then
            self:destroy()
            return
        end
        local max_width = math.floor(wininfo.width * 0.5)
        local width = 0
        lines = vim.iter(lines)
            :map(function(line)
                local l, w = uiutils.truncate_line(line, max_width)
                width = math.max(w, width)
                return l
            end)
            :totable()
        local win_opts = {
            relative = "win",
            win = wininfo.winid,
            anchor = "NE",
            row = 0,
            col = wininfo.width,
            width = width,
            height = #lines,
        }
        local bufnr
        if self.winid and vim.api.nvim_win_is_valid(self.winid) then
            vim.api.nvim_win_set_config(self.winid, win_opts)
            bufnr = vim.api.nvim_win_get_buf(self.winid)
        else
            self.winid, bufnr = uiutils.open_win_buf(win_opts)
        end
        uiutils.set_lines(bufnr, lines, highlights)
    end
    return Top
end

---@return sense.Indicator
function M.gen_virtualtext_bot(render_line)
    local Bot = {}
    Bot.__index = Bot
    function Bot:new(winid)
        return setmetatable({ target_winid = winid }, self)
    end
    function Bot:destroy()
        if self.winid and vim.api.nvim_win_is_valid(self.winid) then
            log.debug("close window", self.winid)
            vim.api.nvim_win_close(self.winid, true)
        end
    end
    ---@param wininfo vim.fn.getwininfo.ret.item
    function Bot:render(wininfo)
        if wininfo.winid ~= self.target_winid then
            return
        end
        local lines, highlights = render_line(wininfo)
        if #lines == 0 then
            self:destroy()
            return
        end
        local max_width = math.floor(wininfo.width * 0.5)
        local width = 0
        lines = vim.iter(lines)
            :map(function(line)
                local l, w = uiutils.truncate_line(line, max_width)
                width = math.max(w, width)
                return l
            end)
            :totable()
        local win_opts = {
            relative = "win",
            win = wininfo.winid,
            anchor = "SE",
            row = wininfo.height,
            col = wininfo.width,
            width = width,
            height = #lines,
        }
        local bufnr
        if self.winid and vim.api.nvim_win_is_valid(self.winid) then
            vim.api.nvim_win_set_config(self.winid, win_opts)
            bufnr = vim.api.nvim_win_get_buf(self.winid)
        else
            self.winid, bufnr = uiutils.open_win_buf(win_opts)
        end
        uiutils.set_lines(bufnr, lines, highlights)
    end
    return Bot
end

return M
