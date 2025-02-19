---@meta
error("Cannot require a meta file")

---@class sense.UI.Highlight
---@field hl_group string
---@field line integer
---@field col_start integer
---@field col_end integer

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

---Captured diagnostics for current window view.
---@class sense.helper.DiagnosticScreenInfo
---diagnostics above the window. Ordered by distance
---@field above vim.Diagnostic[]
---diagnostics below the window. Ordered by distance
---@field below vim.Diagnostic[]
---diagnostic on the top-edge line in current window
---@field top_edge? vim.Diagnostic
---diagnostic on the bottom-edge line in current window
---@field bot_edge? vim.Diagnostic
