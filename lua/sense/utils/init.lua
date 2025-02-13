local M = {}

---@param text string
---@param width number
---@return string text offset-applied text
---@return number offset offset amount (unsigned)
function M.align_right(text, width)
    local offset = math.max(width - vim.fn.strdisplaywidth(text), 0)
    text = string.rep(" ", offset) .. text
    return text, offset
end

local upper = function(str)
    return str:gsub("^%l", string.upper)
end
function M.severity_to_text(severity)
    return upper(string.lower(vim.diagnostic.severity[severity]))
end

return M
