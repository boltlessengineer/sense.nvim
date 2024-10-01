local config = require("sense.config")
local log = require("sense.log")
local statuscol = require("sense.ui.statuscol")
local virtual = require("sense.ui.virtual")

local M = {
    indicators = {}
}

if config.indicators.virtualtext.enabled then
    ---@diagnostic disable-next-line: invisible
    table.insert(M.indicators, virtual.top)
    ---@diagnostic disable-next-line: invisible
    table.insert(M.indicators, virtual.bot)
end
if config.indicators.statuscolumn.enabled then
    ---@diagnostic disable-next-line: invisible
    table.insert(M.indicators, statuscol.top)
    ---@diagnostic disable-next-line: invisible
    table.insert(M.indicators, statuscol.bot)
end

---@param wininfo vim.fn.getwininfo.ret.item
function M.update(wininfo)
    log.debug("ui.update")
    vim.iter(M.indicators):map(function (c)
        log.debug("rendering", c.name)
        c:render(wininfo)
    end)
end

function M.close(wininfo)
    vim.iter(M.indicators):map(function (c)
        log.debug("closing", c.name)
        c:close(wininfo)
    end)
end

return M
