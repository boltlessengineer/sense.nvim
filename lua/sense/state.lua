local M = {}

---@type table<integer, vim.Diagnostic[]>
M.diag_cache = {}

---@param buf number
---@return boolean
function M.is_buf_tracked(buf)
    return M.diag_cache[buf] and true or false
end

return M
