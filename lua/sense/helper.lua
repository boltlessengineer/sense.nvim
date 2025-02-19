local M = {}

---@param wininfo vim.fn.getwininfo.ret.item
---@return sense.helper.DiagnosticScreenInfo screen
function M.capture_diagnostics(wininfo)
    local diags = vim.diagnostic.get(wininfo.bufnr)
    local diags_above = {}
    local diags_below = {}
    ---@type vim.Diagnostic?, vim.Diagnostic?
    local diag_top_edge_item, diag_bot_edge_item
    local is_bottom_visible = wininfo.botline - wininfo.topline + 1 < wininfo.height
    for _, diag in ipairs(diags) do
        if diag.lnum + 1 == wininfo.topline then
            diag_top_edge_item = diag
        end
        if diag.end_lnum + 1 < wininfo.topline then
            table.insert(diags_above, diag)
        end
        if not is_bottom_visible then
            if diag.lnum + 1 == wininfo.botline then
                diag_bot_edge_item = diag
            elseif diag.lnum + 1 > wininfo.botline then
                table.insert(diags_below, diag)
            end
        end
    end
    -- sort in reverse order (closest comes first)
    table.sort(diags_above, function(a, b)
        if a.lnum == b.lnum then
            return a.col > b.col
        end
        return a.lnum > b.lnum
    end)
    table.sort(diags_below, function(a, b)
        if a.lnum == b.lnum then
            return a.col < b.col
        end
        return a.lnum < b.lnum
    end)
    return {
        above = diags_above,
        top_edge = diag_top_edge_item,
        bot_edge = diag_bot_edge_item,
        below = diags_below,
    }
end

return M
