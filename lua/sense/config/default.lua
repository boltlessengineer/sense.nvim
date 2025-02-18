---@class sense.Opts.Indicator
---@field enabled? boolean
---@field level? number
---@field max_count? number
---@field win_config? vim.api.keyset.win_config
---@field render_top? fun(wininfo: vim.fn.getwininfo.ret.item): string[], sense.UI.Highlight[]
---@field render_bot? fun(wininfo: vim.fn.getwininfo.ret.item): string[], sense.UI.Highlight[]

---@class sense.Config
local default_config = {
    ---@class sense.Config.Presets
    presets = {
        ---@class sense.Config.Presets.VirtualText
        virtualtext = {
            ---@type boolean
            enabled = true,
            ---@type integer
            max_count = 1,
        },
        ---@class sense.Config.Presets.StatusColumn
        statuscolumn = {
            ---@type boolean
            enabled = true,
            ---@type integer
            max_count = 1,
        },
    },
    _log_level = vim.log.levels.WARN,
}

return default_config
