---@mod sense.config sense.nvim configuration
---
---@brief [[
---
--- sense.nvim configuration options
---
--- You can set sense.nvim configuration options via `vim.g.sense_nvim`.
---
--->lua
--- ---@type sense.Opts
--- vim.g.sense_nvim
---<
---
---@brief ]]

---@type sense.Config
local config

---@tag vim.g.sense_nvim
---@tag g:sense_nvim
---@class sense.Opts
---Preset components config
---@field presets? sense.Opts.Presets

---@class sense.Opts.Presets
---Config for diagnostic virtualtest component
---@field virtualtext? sense.Opts.Presets.VirtualText
---Config for diagnotics statuscolumn component
---@field statuscolumn? sense.Opts.Presets.StatusColumn

---@class sense.Opts.Presets.VirtualText
---Enable diagnostic virtualtext component
---@field enabled boolean
---Max width of virtualtext component.
---Setting this to lower than 1 will be treated as ratio of max width based on
---the window it is attached to.
---@field max_width number

---@class sense.Opts.Presets.StatusColumn
---Enable diagnostic statuscolumn component
---@field enabeld boolean

---@type sense.Opts
vim.g.sense_nvim = vim.g.sense_nvim

local default_config = require("sense.config.default")

local check = require("sense.config.check")
local opts = vim.g.sense_nvim or {}
config = vim.tbl_deep_extend("force", default_config, opts)
---@cast config sense.Config
local ok, err = check.validate(config)

if not ok then
    ---@cast err string
    vim.notify(err, vim.log.levels.ERROR, { title = "sense.nvim" })
end

return config
