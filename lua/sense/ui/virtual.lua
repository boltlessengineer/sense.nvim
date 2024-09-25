local helper = require("sense.helper")
local ui_utils = require("sense.ui.utils")

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
    if closest.source then
        line = line .. " [" .. closest.source .. "]"
    end
    local highlight = {
        line = 0,
        hl_group = "DiagnosticVirtualTextError",
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
    local line = ("↓ %d lines below"):format(distance)
    if closest.source then
        line = line .. " [" .. closest.source .. "]"
    end
    local highlight = {
        line = 0,
        hl_group = "DiagnosticVirtualTextError",
        col_start = 0,
        col_end = -1,
    }
    return { line }, { highlight }
end

local function open_win(win_pos)
    local win_opts = vim.tbl_deep_extend("force", win_pos, {
        focusable = false,
        style = "minimal",
        zindex = 10,
    })
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, false, win_opts)
    local winhighlight = table.concat({
        "NormalNC:Comment",
    }, ",")
    vim.api.nvim_set_option_value("winhighlight", winhighlight, { win = win })
    vim.api.nvim_set_option_value("winblend", 100, { win = win })
    return win, buf
end

---@param calc_pos fun(wininfo: vim.fn.getwininfo.ret.item, width: number, height: number): vim.api.keyset.win_config
---@param render_fn fun(wininfo: vim.fn.getwininfo.ret.item): string[], sense.UI.Highlight[]
---@return sense.UI.Component
local function gen_virtual_ui(name, calc_pos, render_fn)
    local var_name = "__sense_nvim_" .. name
    ---@param wininfo vim.fn.getwininfo.ret.item
    ---@param width number
    ---@param height number
    ---@return number win
    ---@return number buf
    local function open(wininfo, width, height)
        local win = vim.w[wininfo.winid][var_name]
        local win_pos = calc_pos(wininfo, width, height)
        local buf
        if win and vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_set_config(win, win_pos)
            buf = vim.api.nvim_win_get_buf(win)
        else
            win, buf = open_win(win_pos)
            if win == 0 then
                return win, buf
            end
            vim.w[wininfo.winid][var_name] = win
        end
        return win, buf
    end
    ---@type sense.UI.Component
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
            local width = 0
            vim.iter(lines):map(function(line)
                width = math.max(width, vim.fn.strdisplaywidth(line))
                -- truncate line if it exceeds the max width (width of parent window)
                if width > wininfo.width then
                    -- FIXME: truncate based on displaywidth
                    line = line:sub(1, width / 2)
                end
            end)
            local win, buf = open(wininfo, width, #lines)

            ui_utils.set_lines(buf, lines, highlights, vim.api.nvim_win_get_width(win))
        end,
    }
end

M.top_ui = gen_virtual_ui("top", function(wininfo, width, height)
    return {
        relative = "win",
        win = wininfo.winid,
        anchor = "NE",
        row = 0,
        col = vim.api.nvim_win_get_width(wininfo.winid),
        width = width,
        height = height,
    }
end, render_top)
M.bot_ui = gen_virtual_ui("bot", function(wininfo, width, height)
    return {
        relative = "win",
        win = wininfo.winid,
        anchor = "SE",
        row = vim.api.nvim_win_get_height(wininfo.winid),
        col = vim.api.nvim_win_get_width(wininfo.winid),
        width = width,
        height = height,
    }
end, render_bot)

return M
