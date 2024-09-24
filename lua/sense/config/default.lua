---options used for default renderer
---@class sense.Config.ui.render.Opts

---@alias sense.Config.ui.render.Fun fun()

---@alias sense.Config.ui.render
---| sense.Config.ui.render.Opts
---| sense.Config.ui.render.Fun

---@class sense.Config
local default_config = {
    ---@class sense.Config.ui
    ui = {
        ---@type sense.Config.ui.render
        render = {
        }
    }
}

return default_config
