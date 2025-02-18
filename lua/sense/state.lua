local M = {}

---@class sense.state.WindowState
---@field indicators sense.Indicator[]

---@type sense.Indicator[] registered indicators
M.indicators = {}

---@type table<integer, sense.state.WindowState>
M.windows = vim.defaulttable(function(_winid)
    return {
        indicators = {}
    }
end)

---@type table<integer, vim.Diagnostic[]>
M.diag_cache = {}

---@param buf number
---@return boolean
function M.is_buf_tracked(buf)
    return M.diag_cache[buf] and true or false
end

return M
