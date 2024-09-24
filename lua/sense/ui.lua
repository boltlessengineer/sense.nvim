local state = require("sense.state")

local M = {}

---@class sense.UI.Highlight
---@field hl_group string
---@field line integer
---@field col_start integer
---@field col_end integer

local MAX_WIDTH = 99999
local RIGHT_PADDING = 0

---Calculate max floating window size based on parent window width
---@param win integer parent window-ID
local function get_appropriate_width(win)
    return math.min(MAX_WIDTH, vim.api.nvim_win_get_width(win)) - RIGHT_PADDING
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

local virtual = {
    ---@param wininfo vim.fn.getwininfo.ret.item
    ---@return string[], sense.UI.Highlight
    top = function(wininfo)
        local diagnostics = state.diag_cache[wininfo.bufnr] or {}
        ---@type vim.Diagnostic[]
        diagnostics = vim.iter(diagnostics)
            :filter(function(diag)
                return diag.end_lnum + 1 < wininfo.topline
            end)
            :totable()
        if #diagnostics == 0 then
            return {}, {}
        end
        table.sort(diagnostics, function(a, b)
            -- reverse sort
            return a.end_lnum > b.end_lnum
        end)
        local cursor_row = vim.api.nvim_win_get_cursor(wininfo.winid)[1]
        local distance = cursor_row - (diagnostics[1].lnum + 1)
        local lines = {
            ("↑ %d lines above"):format(distance),
        }
        local highlights = {
            {
                line = 0,
                hl_group = "DiagnosticVirtualTextError",
                col_start = 0,
                col_end = -1,
            },
        }
        return lines, highlights
    end,
    ---@param wininfo vim.fn.getwininfo.ret.item
    bot = function(wininfo)
        local diagnostics = state.diag_cache[wininfo.bufnr] or {}
        ---@type vim.Diagnostic[]
        diagnostics = vim.iter(diagnostics)
            :filter(function(diag)
                return diag.lnum + 1 > wininfo.botline
            end)
            :totable()
        if #diagnostics == 0 then
            return {}, {}
        end
        table.sort(diagnostics, function(a, b)
            return a.lnum < b.lnum
        end)
        local cursor_row = vim.api.nvim_win_get_cursor(wininfo.winid)[1]
        local distance = (diagnostics[1].lnum + 1) - cursor_row
        local lines = {
            ("↓ %d lines below"):format(distance),
        }
        local highlights = {
            {
                line = 0,
                hl_group = "DiagnosticVirtualTextError",
                col_start = 0,
                col_end = -1,
            },
        }
        return lines, highlights
    end,
}

local function set_lines(win, buf, lines, highlights)
    ---@type integer[]
    local offsets = {}
    local width = get_appropriate_width(win)
    -- Right justify each line by padding spaces
    for l, line in ipairs(lines) do
        local offset = width - vim.fn.strdisplaywidth(line)
        lines[l] = string.rep(" ", offset) .. lines[l]
        offsets[l] = offset
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    for _, highlight in ipairs(highlights) do
        local offset = offsets[highlight.line + 1]
        vim.api.nvim_buf_add_highlight(
            buf,
            0,
            highlight.hl_group,
            highlight.line,
            highlight.col_start + offset,
            highlight.col_end == -1 and -1 or highlight.col_end + offset
        )
    end
end

---@param wininfo vim.fn.getwininfo.ret.item
function M.update_top(wininfo)
    local lines, highlights = virtual.top(wininfo)
    local win = vim.w[wininfo.winid].__sense_top_winid
    if #lines == 0 then
        if win then
            vim.w[wininfo.winid].__sense_top_winid = nil
            -- TODO: catch error
            -- this fails on `:edit`
            pcall(vim.api.nvim_win_close, win, true)
        end
        return
    end

    ---@type vim.api.keyset.win_config
    local win_pos = {
        relative = "win",
        win = wininfo.winid,
        anchor = "NE",
        row = 0,
        col = vim.api.nvim_win_get_width(wininfo.winid),
        width = get_appropriate_width(wininfo.winid),
        height = #lines,
    }
    local buf
    if win then
        -- reposition the floating window
        vim.api.nvim_win_set_config(win, win_pos)
        buf = vim.api.nvim_win_get_buf(win)
    else
        win, buf = open_win(win_pos)
        if win == 0 then
            -- TODO: error occured when opening window
            return
        end
        vim.w[wininfo.winid].__sense_top_winid = win
    end

    set_lines(win, buf, lines, highlights)
end

---@param wininfo vim.fn.getwininfo.ret.item
function M.update_bot(wininfo)
    local lines, highlights = virtual.bot(wininfo)
    local win = vim.w[wininfo.winid].__sense_bot_winid
    if #lines == 0 then
        if win then
            vim.w[wininfo.winid].__sense_bot_winid = nil
            -- TODO: catch error
            -- this fails on `:edit`
            pcall(vim.api.nvim_win_close, win, true)
        end
        return
    end

    ---@type vim.api.keyset.win_config
    local win_pos = {
        relative = "win",
        win = wininfo.winid,
        anchor = "SE",
        row = vim.api.nvim_win_get_height(wininfo.winid),
        col = vim.api.nvim_win_get_width(wininfo.winid),
        width = get_appropriate_width(wininfo.winid),
        height = #lines,
    }
    local buf
    if win then
        -- reposition the floating window
        vim.api.nvim_win_set_config(win, win_pos)
        buf = vim.api.nvim_win_get_buf(win)
    else
        win, buf = open_win(win_pos)
        if win == 0 then
            -- TODO: error occured when opening window
            return
        end
        vim.w[wininfo.winid].__sense_bot_winid = win
    end

    set_lines(win, buf, lines, highlights)
end

---@param wininfo vim.fn.getwininfo.ret.item
function M.update(wininfo)
    M.update_top(wininfo)
    M.update_bot(wininfo)
end

return M
