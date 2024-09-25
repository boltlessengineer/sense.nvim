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
    -- sort in reverse order (closer comes first)
    table.sort(ds, function(a, b)
        if a.lnum == b.lnum then
            return a.col > b.col
        end
        return a.lnum > b.lnum
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
        if a.lnum == b.lnum then
            return a.col < b.col
        end
        return a.lnum < b.lnum
    end)
    return diagnostics
end

return M
