if vim.g.loaded_sense_nvim then
    return
end

local api = require("sense.api")
local config = require("sense.config")

-- load custom highlights
require("sense.highlights")

if config.presets.virtualtext.enabled then
    local DiagnosticVirtualText = require("sense.presets.diagnostic").DiagnosticVirtualText
    api.register_renderer(DiagnosticVirtualText)
end
if config.presets.statuscolumn.enabled then
    local DiagnosticStatusCol = require("sense.presets.diagnostic").DiagnosticStatusCol
    api.register_renderer(DiagnosticStatusCol)
end

vim.g.loaded_sense_nvim = true
