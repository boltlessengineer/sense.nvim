local state = require("sense.state")

local M = {}

---@param wininfo vim.fn.getwininfo.ret.item
---@return vim.Diagnostic[]
function M.get_diags_above(wininfo)
    local ds = state.diag_cache[wininfo.bufnr] or {}
    ds = vim.iter(ds)
        :filter(function(diag)
            return diag.end_lnum + 1 < wininfo.topline
        end)
        :totable()
    table.sort(ds, function(a, b)
        -- sort in reverse order (closer comes first)
        return a.end_lnum > b.end_lnum
    end)
    return ds
end

function M.get_diags_below(wininfo)
    local diagnostics = state.diag_cache[wininfo.bufnr] or {}
    diagnostics = vim.iter(diagnostics)
        :filter(function(diag)
            return diag.lnum + 1 > wininfo.botline
        end)
        :totable()
    table.sort(diagnostics, function(a, b)
        return a.lnum < b.lnum
    end)
    return diagnostics
end

return M
