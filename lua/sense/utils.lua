local M = {}

---@param text string
---@param width number
function M.align_right(text, width)
    local offset = width - vim.fn.strdisplaywidth(text)
    text = string.rep(" ", offset) .. text
    return text, offset
end

return M
