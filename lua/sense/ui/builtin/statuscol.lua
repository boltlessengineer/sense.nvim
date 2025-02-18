local log = require("sense.log")
local helper = require("sense.helper")
local utils = require("sense.utils")
local uiutils = require("sense.utils.uiutils")

local M = {}

---@param prefix string
---@param diagnostic vim.Diagnostic
---@param wininfo vim.fn.getwininfo.ret.item
---@return string[], sense.UI.Highlight[]
local function render_fn(prefix, diagnostic, wininfo)
    local cursor_row = vim.api.nvim_win_get_cursor(wininfo.winid)[1]
    local distance = math.abs(cursor_row - (diagnostic.lnum + 1))
    local distance_str =
        utils.align_right(tostring(distance), wininfo.textoff - vim.fn.strdisplaywidth(prefix) - 1)
    local line = prefix .. distance_str .. " "
    local hl_group = "SenseStatusCol" .. utils.severity_to_text(diagnostic.severity)
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
    local prefix = "↑ "
    return render_fn(prefix, closest, wininfo)
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
    local prefix = "↓ "
    return render_fn(prefix, closest, wininfo)
end

---@return sense.Indicator
function M.gen_statuscol_top(render_line)
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
    function Top:render(wininfo)
        if wininfo.winid ~= self.target_winid then
            return
        end
        local lines, highlights = render_line(wininfo)
        if #lines == 0 then
            self:destroy()
            return
        end
        local win_opts = {
            relative = "win",
            win = wininfo.winid,
            anchor = "NW",
            row = 0,
            col = 0,
            width = wininfo.textoff,
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

function M.gen_statuscol_bot(render_line)
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
    function Bot:render(wininfo)
        if wininfo.winid ~= self.target_winid then
            return
        end
        local lines, highlights = render_line(wininfo)
        if #lines == 0 then
            self:destroy()
            return
        end
        local win_opts = {
            relative = "win",
            win = wininfo.winid,
            anchor = "SW",
            row = wininfo.height,
            col = 0,
            width = wininfo.textoff,
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
