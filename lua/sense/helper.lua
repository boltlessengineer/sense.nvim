local log = require("sense.log")
local state = require("sense.state")

local M = {}

---@param wininfo vim.fn.getwininfo.ret.item
---@return vim.Diagnostic[], vim.Diagnostic?
function M.get_diags_above(wininfo)
    local ds = state.diag_cache[wininfo.bufnr] or {}
    log.debug("helper.get_diags_above")
    local edge_item
    ds = vim.iter(ds)
        :filter(function(diag)
            if diag.end_lnum + 1 == wininfo.topline then
                edge_item = diag
            end
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
    return ds, edge_item
end

---@param wininfo vim.fn.getwininfo.ret.item
---@return vim.Diagnostic[], vim.Diagnostic?
function M.get_diags_below(wininfo)
    if wininfo.botline - wininfo.topline + 1 < wininfo.height then
        log.debug("buffer bottom is visible in current window, return empty diagnostics")
        return {}
    end
    local diagnostics = state.diag_cache[wininfo.bufnr] or {}
    local edge_item
    diagnostics = vim.iter(diagnostics)
        :filter(function(diag)
            if diag.lnum + 1 == wininfo.botline then
                edge_item = diag
            end
            return diag.lnum + 1 > wininfo.botline
        end)
        :totable()
    table.sort(diagnostics, function(a, b)
        if a.lnum == b.lnum then
            return a.col < b.col
        end
        return a.lnum < b.lnum
    end)
    return diagnostics, edge_item
end

return M
