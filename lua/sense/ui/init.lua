local log = require("sense.log")
local state = require("sense.state")

local M = {}

function M.attach(winid)
    if #state.windows[winid].indicators > 0 then
        return
    end
    for _, i in ipairs(state.indicators) do
        table.insert(state.windows[winid].indicators, i:new(winid))
    end
    log.debug("attached to window:", state.windows)
end

function M.detach(winid)
    for _, i in ipairs(state.windows[winid].indicators) do
        i:destroy()
    end
    state.windows[winid] = nil
end

function M.render(wininfo)
    M.attach(wininfo.winid)
    for _, c in ipairs(state.windows[wininfo.winid].indicators) do
        c:render(wininfo)
    end
end

return M
