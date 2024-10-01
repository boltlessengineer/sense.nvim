---@class sense.Opts.Indicator
---@field enabled? boolean
---@field level? number
---@field max_count? number
---@field win_config? vim.api.keyset.win_config
---@field render_top? fun(wininfo: vim.fn.getwininfo.ret.item): string[], sense.UI.Highlight[]
---@field render_bot? fun(wininfo: vim.fn.getwininfo.ret.item): string[], sense.UI.Highlight[]

---@class sense.Config
local default_config = {
    ---@type table<string, sense.Opts.Indicator>
    indicators = {
        -- general settings
        ["*"] = {
            level = vim.diagnostic.severity.WARN,
            max_count = 1,
            win_config = {
                zindex = 10,
            }
        },
        virtualtext = {
            enabled = true,
            -- options used from builtin renderer
            max_count = 1,
            win_config = {
                variables = {
                    winblend = 80,
                    winhighlight = "",
                },
            },
        },
        statuscolumn = {
            enabled = true,
            render_top = function (wininfo)
                if vim.wo[wininfo.winid].statuscolumn ~= "" then
                    return {}, {}
                end
                return require("sense.ui.statuscol").render_top(wininfo)
            end,
            render_bot = function (wininfo)
                if vim.wo[wininfo.winid].statuscolumn ~= "" then
                    return {}, {}
                end
                return require("sense.ui.statuscol").render_bot(wininfo)
            end,
        },
    },
    _log_level = vim.log.levels.WARN,
}

return default_config
