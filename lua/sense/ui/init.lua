local config = require("sense.config")
local log = require("sense.log")
local statuscol = require("sense.ui.statuscol")
local virtual = require("sense.ui.virtual")

local M = {
    components = {}
}

if config.indicators.virtualtext.enabled then
    table.insert(M.components, virtual.top)
    table.insert(M.components, virtual.bot)
end
if config.indicators.statuscolumn.enabled then
    table.insert(M.components, statuscol.top)
    table.insert(M.components, statuscol.bot)
end

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
    log.debug("ui.update")
    vim.iter(M.components):map(function (c)
        c:render(wininfo)
    end)
end

function M.close(wininfo)
    vim.iter(M.components):map(function (c)
        c:close(wininfo)
    end)
end

return M
