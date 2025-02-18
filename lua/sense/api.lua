local state = require("sense.state")
local autocmds = require("sense.autocmds")

local M = {}

---@param indicator sense.Indicator
function M.register(indicator)
    -- HACK: when used as lua-module and not as neovim plugin, try setup autocmds here
    if not vim.g.loaded_sense_nvim then
        autocmds.setup()
        vim.g.loaded_sense_nvim = true
    end
    table.insert(state.indicators, indicator)
end

function M.clear_registered()
    state.indicators = {}
end

return M
