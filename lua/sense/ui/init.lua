local virtual = require("sense.ui.virtual")

local M = {}

---@class sense.UI.Highlight
---@field hl_group string
---@field line integer
---@field col_start integer
---@field col_end integer

---@class sense.UI.Component
local component = {}
---@param wininfo vim.fn.getwininfo.ret.item
function component:close(wininfo)
    wininfo = wininfo
end
---@param wininfo vim.fn.getwininfo.ret.item
function component:render(wininfo)
    wininfo = wininfo
end

---@param wininfo vim.fn.getwininfo.ret.item
function M.update(wininfo)
    virtual.top_ui:render(wininfo)
    virtual.bot_ui:render(wininfo)
end

function M.close(wininfo)
    virtual.top_ui:close(wininfo)
    virtual.bot_ui:close(wininfo)
end

return M
