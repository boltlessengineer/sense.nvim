local config = require("sense.config")
local helper = require("sense.helper")
local log = require("sense.log")
local ui = require("sense.ui")

local M = {}

---@param severity vim.diagnostic.Severity
---@return string
local function severity_to_text(severity)
    local str = string.lower(vim.diagnostic.severity[severity]):gsub("^%l", string.upper)
    return str
end

M.DiagnosticVirtualText = ui.virtualtext.create({
    name = "diagnostic",
    on_init = function(self)
        vim.api.nvim_create_autocmd("DiagnosticChanged", {
            group = vim.api.nvim_create_augroup("sense.builtin.diagnostic.virtualtext", { clear = true }),
            callback = function(ev)
                log.debug("re-render itself on diagnostic changed event")
                vim.iter(vim.fn.getwininfo())
                :filter(function(info)
                    return info.bufnr == ev.buf
                end)
                :map(function(info)
                    self:render(info)
                end)
            end,
        })
    end,
    render_lines = function(wininfo)
        local screen = helper.capture_diagnostics(wininfo)
        local above = (function()
            local closest = screen.above[1]
            if not closest then
                return
            elseif screen.top_edge and screen.top_edge.severity <= closest.severity then
                return
            end
            local cursor_row = vim.api.nvim_win_get_cursor(wininfo.winid)[1]
            local distance = cursor_row - (closest.lnum + 1)
            local line = (" ↑ %d lines above"):format(distance)
            local msg = vim.split(closest.message, "[\n\r]")[1]
            line = line .. " [" .. msg .. "] "
            local hl_group = "SenseVirtualText" .. severity_to_text(closest.severity)
            local highlight = {
                hl_group = hl_group,
                line = 0,
                col_start = 0,
                col_end = -1,
            }
            return { lines = { line }, highlights = { highlight } }
        end)()
        local below = (function()
            local closest = screen.below[1]
            if not closest then
                return
            elseif screen.bot_edge and screen.bot_edge.severity <= closest.severity then
                return { lines = {}, highlights = {} }
            end
            local cursor_row = vim.api.nvim_win_get_cursor(wininfo.winid)[1]
            local distance = (closest.lnum + 1) - cursor_row
            local line = (" ↓ %d lines below"):format(distance)
            local msg = vim.split(closest.message, "[\n\r]")[1]
            line = line .. " [" .. msg .. "] "
            local hl_group = "SenseVirtualText" .. severity_to_text(closest.severity)
            local highlight = {
                hl_group = hl_group,
                line = 0,
                col_start = 0,
                col_end = -1,
            }
            return { lines = { line }, highlights = { highlight } }
        end)()
        return {
            above = above,
            below = below,
        }
    end,
    max_width = config.presets.virtualtext.max_width,
})

M.DiagnosticStatusCol = ui.statuscol.create({
    name = "diagnostic",
    on_init = function(self)
        local group = vim.api.nvim_create_augroup("sense.builtin.diagnostic.statuscol", { clear = true })
        vim.api.nvim_create_autocmd("DiagnosticChanged", {
            group = group,
            callback = function(ev)
                log.debug("re-render itself on diagnostic changed event")
                vim.iter(vim.fn.getwininfo())
                    :filter(function(info)
                        return info.bufnr == ev.buf
                    end)
                    :map(function(info)
                        self:render(info)
                    end)
            end,
        })
        vim.api.nvim_create_autocmd("OptionSet", {
            group = group,
            pattern = { "foldcolumn", "number", "relativenumber", "signcolumn" },
            callback = function(_ev)
                log.debug("re-render itself on diagnostic changed event")
                vim.iter(vim.fn.getwininfo())
                    :map(function(info)
                        self:render(info)
                    end)
            end,
        })
    end,
    render_lines = function(wininfo)
        local screen = helper.capture_diagnostics(wininfo)
        local above = (function()
            local closest = screen.above[1]
            if not closest then
                return
            elseif screen.top_edge and screen.top_edge.severity <= closest.severity then
                return
            end
            local cursor_row = vim.api.nvim_win_get_cursor(wininfo.winid)[1]
            local distance = cursor_row - (closest.lnum + 1)
            local prefix, rnu_text = " ↑", tostring(distance) .. " "
            local line = prefix .. string.rep(" ", wininfo.textoff - vim.fn.strdisplaywidth(prefix .. rnu_text)) .. rnu_text
            local hl_group = "SenseStatusCol" .. severity_to_text(closest.severity)
            local highlight = {
                hl_group = hl_group,
                line = 0,
                col_start = 0,
                col_end = -1,
            }
            return { lines = { line }, highlights = { highlight } }
        end)()
        local below = (function()
            local closest = screen.below[1]
            if not closest then
                return
            elseif screen.bot_edge and screen.bot_edge.severity <= closest.severity then
                return
            end
            local cursor_row = vim.api.nvim_win_get_cursor(wininfo.winid)[1]
            local distance = (closest.lnum + 1) - cursor_row
            local prefix, rnu_text = " ↓", tostring(distance) .. " "
            local line = prefix .. string.rep(" ", wininfo.textoff - vim.fn.strdisplaywidth(prefix .. rnu_text)) .. rnu_text
            local hl_group = "SenseStatusCol" .. severity_to_text(closest.severity)
            local highlight = {
                hl_group = hl_group,
                line = 0,
                col_start = 0,
                col_end = -1,
            }
            return { lines = { line }, highlights = { highlight } }
        end)()
        return {
            above = above,
            below = below,
        }
    end,
})

return M
