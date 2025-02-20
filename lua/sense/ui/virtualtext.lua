---@mod sense.ui.statuscol Builtin VirtualText UI element

-- stylua: ignore start
local function log() return require("sense.log") end
local function utils() return require("sense.utils") end
-- stylua: ignore end

local M = {}

---@class sense.ui.virtualtext.create.Opts
---Unique name used to save & restore UI state on each windows
---@field name string
---Called on Indicator:init()
---@field on_init? fun(self: sense.Indicator)
---Abstracted version of Indicator:render()
---@field render_lines fun(wininfo: vim.fn.getwininfo.ret.item): sense.ui.TopBotLines?
---Max width of virtualtext. See |sense.Opts.presets.virtualtext.max_width|.
---@field max_width? number

---@param opts sense.ui.virtualtext.create.Opts
---@return sense.Indicator
function M.create(opts)
    opts.max_width = opts.max_width or 0.5
    local top_varname = ("__sense_%s_top_virtualtext_winid"):format(opts.name)
    local bot_varname = ("__sense_%s_bot_virtualtext_winid"):format(opts.name)
    local VirtualText = {}
    function VirtualText:init()
        if opts.on_init then
            opts.on_init(self)
        end
    end
    ---@param wininfo vim.fn.getwininfo.ret.item
    function VirtualText:render(wininfo)
        local max_width = utils().calc_size_config(opts.max_width, wininfo.width)
        local data = opts.render_lines(wininfo)
        data = data or {}
        data.above = data.above or { lines = {}, highlights = {} }
        data.below = data.below or { lines = {}, highlights = {} }
        do
            local lines, highlights = data.above.lines, data.above.highlights
            local width = 0
            lines = vim.iter(lines)
                :map(function(line)
                    local l, w = utils().truncate_line(line, max_width)
                    width = math.max(w, width)
                    return l
                end)
                :totable()
            log().debug("lines", lines)
            utils().restore_and_open_win(
                top_varname,
                wininfo,
                lines,
                highlights,
                {
                    relative = "win",
                    win = wininfo.winid,
                    anchor = "NE",
                    row = 0,
                    col = wininfo.width,
                    width = width,
                    height = #lines,
                }
            )
        end
        do
            local lines, highlights = data.below.lines, data.below.highlights
            local width = 0
            lines = vim.iter(lines)
                :map(function(line)
                    local l, w = utils().truncate_line(line, max_width)
                    width = math.max(w, width)
                    return l
                end)
                :totable()
            log().debug("lines", lines)
            utils().restore_and_open_win(
                bot_varname,
                wininfo,
                lines,
                highlights,
                {
                    relative = "win",
                    win = wininfo.winid,
                    anchor = "SE",
                    row = wininfo.height,
                    col = wininfo.width,
                    width = width,
                    height = #lines,
                }
            )
        end
    end
    return VirtualText
end

return M
