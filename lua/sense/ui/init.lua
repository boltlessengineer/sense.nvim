local M = {}

---@class sense.ui.TopBotLines
---@field above? { lines: string[], highlights: sense.UI.Highlight }
---@field below? { lines: string[], highlights: sense.UI.Highlight }

M.virtualtext = require("sense.ui.virtualtext")
M.statuscol = require("sense.ui.statuscol")

return M
