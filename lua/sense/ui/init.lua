local config = require("sense.config")
local log = require("sense.log")
local statuscol = require("sense.ui.builtin.statuscol")
local virtualtext = require("sense.ui.builtin.virtualtext")
-- local virtual = require("sense.ui.virtual")

local M = {
    ---@type sense.Indicator[]
    indicators = {},
    ---@type table<integer, sense.Indicator[]>
    windows = {},
}

if config.presets.virtualtext.enabled then
    table.insert(M.indicators, virtualtext.gen_virtualtext_top(virtualtext.render_diagnostic_top))
    table.insert(M.indicators, virtualtext.gen_virtualtext_bot(virtualtext.render_diagnostic_bot))
end
if config.presets.statuscolumn.enabled then
    table.insert(M.indicators, statuscol.gen_statuscol_top(statuscol.render_diagnostic_top))
    table.insert(M.indicators, statuscol.gen_statuscol_bot(statuscol.render_diagnostic_bot))
end

function M.attach(winid)
    M.windows[winid] = M.windows[winid] or {}
    if #M.windows[winid] > 0 then
        return
    end
    for _, i in ipairs(M.indicators) do
        table.insert(M.windows[winid], i:new(winid))
    end
    log.debug("attached to window:", M.windows)
end

function M.detach(winid)
    for _, i in ipairs(M.windows[winid]) do
        i:destroy()
    end
    M.windows[winid] = nil
end

function M.render(wininfo)
    M.attach(wininfo.winid)
    for _, c in ipairs(M.windows[wininfo.winid]) do
        c:render(wininfo)
    end
end

return M
