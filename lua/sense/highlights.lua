local M = {}

local function dec_to_rgb(num)
    return {
        r = bit.rshift(num, 16),
        g = bit.band(bit.rshift(num, 8), 0xFF),
        b = bit.band(num, 0xFF),
    }
end

local function rgb_to_dec(rgb)
    return bit.lshift(rgb.r, 16) + bit.lshift(rgb.g, 8) + rgb.b
end

---@param ns_id integer
---@param opts vim.api.keyset.get_highlight
local function read_hl(ns_id, opts)
    opts.link = false
    local hl = vim.api.nvim_get_hl(ns_id, opts)
    local rich_hl = {}
    if vim.tbl_isempty(hl) then
        return
    end
    rich_hl.fg = hl.fg and dec_to_rgb(hl.fg)
    rich_hl.bg = hl.bg and dec_to_rgb(hl.bg)
    return rich_hl
end

---@param c table A hex color
---@param percent number a negative number darkens and a positive one brightens
local function tint(c, percent)
    if not c.r or not c.g or not c.b then
        return "NONE"
    end
    local blend = function(component)
        component = math.floor(component * (1 + percent))
        return math.min(math.max(component, 0), 255)
    end
    return {
        r = blend(c.r),
        g = blend(c.g),
        b = blend(c.b),
    }
end

local function set(name, from)
    local hl = read_hl(0, { name = from, link = false })
    if hl and hl.fg and not hl.bg then
        hl.bg = rgb_to_dec(tint(hl.fg, -0.8))
        hl.fg = hl.fg and rgb_to_dec(hl.fg)
    else
        hl = { link = from }
    end
    vim.api.nvim_set_hl(0, name, hl)
end

function M.setup()
    -- generate hl-groups based on existing colors
    set("SenseVirtualTextError", "DiagnosticVirtualTextError")
    set("SenseVirtualTextWarn", "DiagnosticVirtualTextWarn")
    set("SenseVirtualTextInfo", "DiagnosticVirtualTextInfo")
    set("SenseVirtualTextHint", "DiagnosticVirtualTextHint")
    set("SenseStatusColError", "DiagnosticVirtualTextError")
    set("SenseStatusColWarn", "DiagnosticVirtualTextWarn")
    set("SenseStatusColInfo", "DiagnosticVirtualTextInfo")
    set("SenseStatusColHint", "DiagnosticVirtualTextHint")
end

return M
