if vim.g.loaded_sense_nvim then return end

local api = require("sense.api")
local config = require("sense.config")
local highlights = require("sense.highlights")
local statuscol = require("sense.ui.builtin.statuscol")
local virtualtext = require("sense.ui.builtin.virtualtext")

api.clear_registered()
if config.presets.virtualtext.enabled then
    api.register(virtualtext.gen_virtualtext_top(virtualtext.render_diagnostic_top))
    api.register(virtualtext.gen_virtualtext_bot(virtualtext.render_diagnostic_bot))
end
if config.presets.statuscolumn.enabled then
    api.register(statuscol.gen_statuscol_top(statuscol.render_diagnostic_top))
    api.register(statuscol.gen_statuscol_bot(statuscol.render_diagnostic_bot))
end

highlights.setup()

vim.g.loaded_sense_nvim = true
