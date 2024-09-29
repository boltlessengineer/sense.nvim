local M = {}

---@param text string
---@param width number
function M.align_right(text, width)
    local offset = width - vim.fn.strdisplaywidth(text)
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
