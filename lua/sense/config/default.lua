---@comment default-config:start
---@class sense.Config
local default_config = {
    ---@class sense.Config.Presets
    presets = {
        ---@class sense.Config.Presets.VirtualText
        virtualtext = {
            ---@type boolean
            enabled = true,
            ---@type number
            max_width = 0.5,
        },
        ---@class sense.Config.Presets.StatusColumn
        statuscolumn = {
            ---@type boolean
            enabled = true,
        },
    },
    _log_level = vim.log.levels.WARN,
}
---@comment default-config:end

return default_config
