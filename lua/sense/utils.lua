local log = require("sense.log")
local utf8 = require("lua-utf8")

local M = {}

---@private
---@param name string
---@param wininfo vim.fn.getwininfo.ret.item
---@param lines string[]
---@param highlights sense.UI.Highlight[]
---@param win_opts vim.api.keyset.win_config
function M.restore_and_open_win(name, wininfo, lines, highlights, win_opts)
    local ok, fwinid = pcall(vim.tbl_get, vim.w, wininfo.winid, name)
    if not ok then
        -- TODO: log error about vim.w.__index error here:
        log.debug("error while reading window variables in", wininfo.winid, fwinid)
        fwinid = nil
    end
    if #lines == 0 then
        log.debug("nothing to render, abort")
        if fwinid and vim.api.nvim_win_is_valid(fwinid) then
            log.debug("close window:", fwinid)
            vim.api.nvim_win_close(fwinid, true)
        end
        return
    end
    local bufnr
    assert(win_opts.width > 0, "width should be positive at this point")
    if fwinid and vim.api.nvim_win_is_valid(fwinid) then
        vim.api.nvim_win_set_config(fwinid, win_opts)
        bufnr = vim.api.nvim_win_get_buf(fwinid)
    else
        fwinid, bufnr = M.open_win_buf(win_opts)
        vim.w[wininfo.winid][name] = fwinid
    end
    M.set_lines(bufnr, lines, highlights)
end

---Render lines & highlights on buffer
---@param buf number
---@param lines string[]
---@param highlights sense.UI.Highlight[]
function M.set_lines(buf, lines, highlights)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    for _, highlight in ipairs(highlights) do
        vim.api.nvim_buf_add_highlight(
            buf,
            0,
            highlight.hl_group,
            highlight.line,
            highlight.col_start,
            highlight.col_end
        )
    end
end

---Fixed version of nvim_open_win
---@param buffer integer
---@param enter boolean
---@param config vim.api.keyset.win_config
---@return integer
function M.nvim_open_win(buffer, enter, config)
    log.debug("utils.nvim_open_win")
    local win = vim.api.nvim_open_win(buffer, enter, config)
    if config.relative == "win" then
        if config.win == 0 then
            config.win = vim.api.nvim_get_current_win()
        end
        -- HACK: close windows when parent window is closed
        -- WHY IS THIS NOT A DEFAULT BEHAVIOR
        vim.api.nvim_create_autocmd("WinClosed", {
            group = vim.api.nvim_create_augroup("sense.fix_nvim_open_win", { clear = false }),
            callback = function(ev)
                if ev.match == tostring(config.win) then
                    if vim.api.nvim_win_is_valid(win) then
                        log.debug("close dangling window:", win)
                        vim.api.nvim_win_close(win, true)
                    end
                    return true
                end
            end,
            desc = "Close floating window associated to window when closed",
        })
    end
    return win
end

---@private
---Open window with scratch buffer
---@param win_config vim.api.keyset.win_config
function M.open_win_buf(win_config)
    log.debug("open_win_buf with", win_config)
    win_config = vim.tbl_deep_extend("force", win_config, {
        focusable = false,
        style = "minimal",
        zindex = 10,
    })
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].buftype = "nofile"
    local win = M.nvim_open_win(buf, false, win_config)
    log.debug("window opened")
    return win, buf
end

---@param str string
---@param max_width integer
---@return string, integer
function M.truncate_line(str, max_width)
    local full_width = vim.fn.strdisplaywidth(str)
    if vim.fn.strdisplaywidth(str) <= max_width then
        return str, full_width
    end
    max_width = max_width - 1
    local result = {}
    full_width = 0
    for _, code in utf8.codes(str) do
        local char = utf8.char(code)
        local w = vim.fn.strdisplaywidth(char)
        if full_width + w > max_width then
            break
        end
        table.insert(result, char)
        full_width = full_width + w
    end
    return table.concat(result) .. "…", full_width + 1
end

---Calculate size given as integer or ratio
---@param size number
---@param base integer
---@return integer
function M.calc_size_config(size, base)
    if size < 1 then
        return math.floor(base * size)
    else
        return math.floor(size)
    end
end

return M
