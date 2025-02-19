local M = {}

---@private
---@type sense.Indicator[]
local indicators = {}

---Register Indicator
---This method will call Indicator:init() immediately.
---@param renderer sense.Indicator
function M.register_renderer(renderer)
    require("sense.autocmds") -- ensure autocmds setup
    renderer:init()
    table.insert(indicators, renderer)
end

---winid can be used instead of wininfo.
---When wininfo exists, winid will be ignored.
---@class sense.api.redraw.Opts
---@field winid? integer
---@field wininfo? vim.fn.getwininfo.ret.item

---Redraw indicators.
---When opts is not given, it will redraw indicators for every existing windows.
---@param opts? sense.api.redraw.Opts
function M.redraw(opts)
    opts = opts or {}
    if not opts.wininfo and opts.winid then
        opts.wininfo = vim.fn.getwininfo(opts.winid)[1]
    end
    if opts.wininfo then
        for _, renderer in ipairs(indicators) do
            renderer:render(opts.wininfo)
        end
    else
        for _, wininfo in ipairs(vim.fn.getwininfo()) do
            for _, renderer in ipairs(indicators) do
                renderer:render(wininfo)
            end
        end
    end
end

return M
