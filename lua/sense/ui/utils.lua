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
            local offset = width - vim.fn.strdisplaywidth(line)
            -- FIXME: handle when offset is negative
            lines[l] = string.rep(" ", offset) .. lines[l]
            offsets[l] = offset
        end
        vim.print(width)
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

return M
