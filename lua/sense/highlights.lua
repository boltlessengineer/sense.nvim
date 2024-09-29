local hlutils = require("sense.utils.hlutils")

local M = {}

local function fill_bg(name)
    local hl = hlutils.read_hl(0, { name = name, link = false })
    assert(hl)
    assert(hl.fg)
    if not hl.bg then
        hl.bg = hlutils.tint(hl.fg, -0.8)
    end
    return hl
end

function M.setup()
    -- generate hl-groups based on existing colors
    hlutils.set_hl("SenseVirtualTextError", fill_bg("DiagnosticVirtualTextError"))
    hlutils.set_hl("SenseVirtualTextWarn", fill_bg("DiagnosticVirtualTextWarn"))
    hlutils.set_hl("SenseVirtualTextInfo", fill_bg("DiagnosticVirtualTextInfo"))
    hlutils.set_hl("SenseVirtualTextHint", fill_bg("DiagnosticVirtualTextHint"))
    hlutils.set_hl("SenseStatusColError", fill_bg("DiagnosticVirtualTextError"))
    hlutils.set_hl("SenseStatusColWarn", fill_bg("DiagnosticVirtualTextWarn"))
    hlutils.set_hl("SenseStatusColInfo", fill_bg("DiagnosticVirtualTextInfo"))
    hlutils.set_hl("SenseStatusColHint", fill_bg("DiagnosticVirtualTextHint"))
end

return M
