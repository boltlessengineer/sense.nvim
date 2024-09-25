local virtual = require("sense.ui.virtual")
local statuscol = require("sense.ui.statuscol")

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
    virtual.top:render(wininfo)
    virtual.bot:render(wininfo)
    statuscol.top:render(wininfo)
end

function M.close(wininfo)
    virtual.top:close(wininfo)
    virtual.bot:close(wininfo)
    statuscol.top:close(wininfo)
end

return M
