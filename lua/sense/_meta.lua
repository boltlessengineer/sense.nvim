---@meta
error('Cannot require a meta file')

---@class sense.Indicator
---@field name string name of indicator
---@field target_winid integer
local Indicator = {}

---@param winid integer
---@return sense.Indicator
function Indicator:new(winid)
    return setmetatable({ name = "", target_winid = winid }, self)
end

function Indicator:destroy()
end

---@param wininfo vim.fn.getwininfo.ret.item
function Indicator:render(wininfo)
    wininfo = wininfo
end

---@class sense.UI.Highlight
---@field hl_group string
---@field line integer
---@field col_start integer
---@field col_end integer
