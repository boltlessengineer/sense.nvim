---@meta
error("Cannot require a meta file")

---@class sense.ui.Highlight
---@field hl_group string
---@field line integer
---@field col_start integer
---@field col_end integer

---Object containing data to render on top & bottom UI components
---@class sense.ui.TopBotLines
---@field above? { lines: string[], highlights: sense.ui.Highlight[] }
---@field below? { lines: string[], highlights: sense.ui.Highlight[] }

---@class sense.Indicator
local Indicator = {}
---Initialize the indicator.
---For example, it can set autocommands to re-render on diagnostic changes here.
function Indicator:init() end
---Actually render the UI element.
---UI element can be any kind. This method is also responsible of removing
---outdated UI elements.
---@param wininfo vim.fn.getwininfo.ret.item
function Indicator:render(wininfo)
    wininfo = wininfo -- placeholder
end
