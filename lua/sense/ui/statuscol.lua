---@mod sense.ui.statuscol Builtin StatusColumn UI element

-- stylua: ignore start
local function utils() return require("sense.utils") end
-- stylua: ignore end

local M = {}

---@class sense.ui.statuscol.create.Opts
---Unique name used to save & restore UI state on each windows
---@field name string
---Called on Indicator:init()
---@field on_init? fun(self: sense.Indicator)
---Abstracted version of Indicator:render()
---@field render_lines fun(wininfo: vim.fn.getwininfo.ret.item): sense.ui.TopBotLines?

---@param opts sense.ui.statuscol.create.Opts
---@return sense.Indicator
function M.create(opts)
    local top_varname = ("__sense_%s_top_statuscol_winid"):format(opts.name)
    local bot_varname = ("__sense_%s_bot_statuscol_winid"):format(opts.name)
    local StatusCol = {}
    function StatusCol:init()
        if opts.on_init then
            opts.on_init(self)
        end
    end
    ---@param wininfo vim.fn.getwininfo.ret.item
    function StatusCol:render(wininfo)
        local width = wininfo.textoff
        if width == 0 then
            utils().restore_and_open_win(top_varname, wininfo, {}, {}, {})
            utils().restore_and_open_win(bot_varname, wininfo, {}, {}, {})
            return
        end
        local data = opts.render_lines(wininfo)
        data = data or {}
        data.above = data.above or { lines = {}, highlights = {} }
        data.below = data.below or { lines = {}, highlights = {} }
        do
            local lines, highlights = data.above.lines, data.above.highlights
            utils().restore_and_open_win(top_varname, wininfo, lines, highlights, {
                relative = "win",
                win = wininfo.winid,
                anchor = "NW",
                row = 0,
                col = 0,
                width = width,
                height = #lines,
            })
        end
        do
            local lines, highlights = data.below.lines, data.below.highlights
            utils().restore_and_open_win(bot_varname, wininfo, lines, highlights, {
                relative = "win",
                win = wininfo.winid,
                anchor = "SW",
                row = wininfo.height,
                col = 0,
                width = width,
                height = #lines,
            })
        end
    end
    return StatusCol
end

return M
