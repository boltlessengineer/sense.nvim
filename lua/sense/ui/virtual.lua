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
    local distance = cursor_row - (closest.lnum + 1)
    local line = ("↑ %d lines above"):format(distance)
    line = line .. " [" .. closest.message .. "]"
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
local function render_bot(wininfo)
    local diagnostics = helper.get_diags_below(wininfo)
    if #diagnostics == 0 then
        return {}, {}
    end
    local closest = diagnostics[1]
    local cursor_row = vim.api.nvim_win_get_cursor(wininfo.winid)[1]
    local distance = (closest.lnum + 1) - cursor_row
    local line = ("↑ %d lines above"):format(distance)
    line = line .. " [" .. closest.message .. "]"
    local hl_group = "SenseVirtualText" .. utils.severity_to_text(closest.severity)
    local highlight = {
        line = 0,
        hl_group = hl_group,
        col_start = 0,
        col_end = -1,
    }
    return { line }, { highlight }
end

---@param calc_pos fun(wininfo: vim.fn.getwininfo.ret.item, width: number, height: number): vim.api.keyset.win_config
---@param render_fn fun(wininfo: vim.fn.getwininfo.ret.item): string[], sense.UI.Highlight[]
---@return sense.UI.Component
local function gen_virtual_ui(name, calc_pos, render_fn)
    local var_name = "__sense_nvim_" .. name
    ---@type sense.UI.Component
    local comp = {
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
            local width = 0
            vim.iter(lines):map(function(line)
                width = math.max(width, vim.fn.strdisplaywidth(line))
                -- truncate line if it exceeds the max width (width of parent window)
                if width > wininfo.width then
                    -- FIXME: truncate based on displaywidth
                    line = line:sub(1, width / 2)
                end
            end)
            local win, buf = (function ()
                local win = vim.w[wininfo.winid][var_name]
                local win_pos = calc_pos(wininfo, width, #lines)
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
            end)()

            ui_utils.set_lines(buf, lines, highlights, vim.api.nvim_win_get_width(win))
        end,
    }
    -- register WinClosed event to close window without passing winid
    return comp
end

M.top = gen_virtual_ui("top", function(wininfo, width, height)
    return {
        relative = "win",
        win = wininfo.winid,
        anchor = "NE",
        row = 0,
        col = wininfo.width,
        width = width,
        height = height,
    }
end, render_top)
M.bot = gen_virtual_ui("bot", function(wininfo, width, height)
    return {
        relative = "win",
        win = wininfo.winid,
        anchor = "SE",
        row = wininfo.height,
        col = wininfo.width,
        width = width,
        height = height,
    }
end, render_bot)

function M.update(wininfo)
    M.top:render(wininfo)
    M.bot:render(wininfo)
end

function M.clear(wininfo)
    M.top:close(wininfo)
    M.bot:close(wininfo)
end

return M
