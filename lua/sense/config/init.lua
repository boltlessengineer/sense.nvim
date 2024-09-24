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

---@class sense.Opts

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
