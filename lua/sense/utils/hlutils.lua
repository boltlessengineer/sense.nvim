local bit = require("bit")

local M = {}

function M.dec_to_rgb(num)
    return {
        r = bit.rshift(num, 16),
        g = bit.band(bit.rshift(num, 8), 0xFF),
        b = bit.band(num, 0xFF),
    }
end

function M.rgb_to_dec(rgb)
    return bit.lshift(rgb.r, 16) + bit.lshift(rgb.g, 8) + rgb.b
end

---@param ns_id integer
---@param opts vim.api.keyset.get_highlight
function M.read_hl(ns_id, opts)
    local hl = vim.api.nvim_get_hl(ns_id, opts)
    local rich_hl = {}
    if vim.tbl_isempty(hl) then
        return nil
    end
    -- if hl.link then
    --     return M.read_hl(ns_id, { name = hl.link })
    -- end
    rich_hl.fg = hl.fg and M.dec_to_rgb(hl.fg)
    rich_hl.bg = hl.bg and M.dec_to_rgb(hl.bg)
    return rich_hl
end

---@param c table A hex color
---@param percent number a negative number darkens and a positive one brightens
function M.tint(c, percent)
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

function M.set_hl(name, hl)
    vim.api.nvim_set_hl(0, name, {
        fg = M.rgb_to_dec(hl.fg),
        bg = M.rgb_to_dec(hl.bg),
    })
end

return M
