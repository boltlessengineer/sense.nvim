---@meta
error('Cannot require a meta file')

---@class sense.UI.Indicator
---@field name string
local component = {}
---@param wininfo vim.fn.getwininfo.ret.item
function component:close(wininfo)
    wininfo = wininfo
end
---@param wininfo vim.fn.getwininfo.ret.item
function component:render(wininfo)
    wininfo = wininfo
end

---@class sense.UI.Highlight
---@field hl_group string
---@field line integer
---@field col_start integer
---@field col_end integer
