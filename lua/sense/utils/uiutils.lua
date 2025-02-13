local log = require("sense.log")
local utils = require("sense.utils")

local M = {}

-- TODO: NOTE: code is from fidget.nvim

---@param buf number
---@param lines string[]
---@param highlights sense.UI.Highlight[]
---@param width number|nil
function M.set_lines(buf, lines, highlights, width)
    ---@type number[]
    local offsets = {}
    if width then
        -- Right justify each line by padding spaces
        for l, line in ipairs(lines) do
            local text, offset = utils.align_right(line, width)
            lines[l] = text
            offsets[l] = offset
        end
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    for _, highlight in ipairs(highlights) do
        local offset = offsets[highlight.line + 1] or 0
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

---Fixed version of nvim_open_win
---@param buffer integer
---@param enter boolean
---@param config vim.api.keyset.win_config
---@return integer
function M.nvim_open_win(buffer, enter, config)
    log.debug("uiutils.nvim_open_win")
    local win = vim.api.nvim_open_win(buffer, enter, config)
    log.debug("nvim_open_win")
    if config.relative == "win" then
        if config.win == 0 then
            config.win = vim.api.nvim_get_current_win()
        end
        -- HACK: close windows when parent window is closed
        -- WHY IS THIS NOT A DEFAULT BEHAVIOR
        vim.api.nvim_create_autocmd("WinClosed", {
            group = vim.api.nvim_create_augroup("sense.fix_nvim_open_win", { clear = false }),
            callback = function (ev)
                if ev.match == tostring(config.win) then
                    if vim.api.nvim_win_is_valid(win) then
                        vim.api.nvim_win_close(win, true)
                    end
                    return true
                end
            end,
            desc = "Close floating window associated to window when closed"
        })
    end
    return win
end

-- TODO(boltless): I'm not sure if I should leave this here
---@param win_config vim.api.keyset.win_config
function M.open_win_buf(win_config)
    log.debug("open_win_buf with", win_config)
    win_config = vim.tbl_deep_extend("force", win_config, {
        focusable = false,
        style = "minimal",
        zindex = 10,
    })
    local buf = vim.api.nvim_create_buf(false, true)
    local win = M.nvim_open_win(buf, false, win_config)
    local winhighlight = table.concat({
        "NormalNC:LineNr",
    }, ",")
    vim.api.nvim_set_option_value("winhighlight", winhighlight, { win = win })
    log.debug("window opened")
    return win, buf
end

return M
