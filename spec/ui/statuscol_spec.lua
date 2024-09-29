---@module 'luassert'

require("spec.minimal_init")

vim.g.sense_nvim = {
    indicators = {
        virtualtext = {
            enabled = false,
        },
        statuscolumn = {
            enabled = true,
        },
    },
}

local ui = require("sense.ui")

local test_ns = vim.api.nvim_create_namespace("sense.test")
local diags = {
    {
        code = "UndeclaredName",
        col = 4,
        end_col = 7,
        end_lnum = 3,
        lnum = 3,
        message = "undefined: fmt",
        severity = 1,
        source = "compiler",
        user_data = {
            lsp = {
                code = "UndeclaredName",
                codeDescription = {
                    href = "https://pkg.go.dev/golang.org/x/tools/internal/typesinternal#UndeclaredName",
                },
            },
        },
    },
}

describe("UI component - statuscol", function()
    local function count_win()
        return #vim.api.nvim_list_wins()
    end
    local function win_is_float(win)
        local c = vim.api.nvim_win_get_config(win)
        return c.relative ~= ""
    end
    local function ui_update_all()
        vim.iter(vim.fn.getwininfo()):map(ui.update)
    end
    before_each(function()
        -- setup options to test with
        vim.o.number = true
        vim.o.relativenumber = true
        vim.o.signcolumn = "yes"
        vim.o.splitright = true
        -- clear all buffers/windows
        vim.cmd("silent! %bwipeout")
        vim.cmd("silent! wincmd o")
        vim.g.fucking_schedule = false
    end)
    it("assert vim window size", function()
        assert.same(vim.o.columns, 80)
        assert.same(vim.o.lines, 24)
        assert.same(vim.o.number, true)
        assert.same(vim.o.relativenumber, true)
        assert.same(vim.o.signcolumn, "yes")
        assert.same(true, require("sense.config").indicators.statuscolumn.enabled)
        assert.same(false, require("sense.config").indicators.virtualtext.enabled)
    end)
    it("textoff", function()
        vim.cmd.wincmd("v")
        local infos = vim.fn.getwininfo()
        assert.same(6, infos[1].textoff)
        assert.same(6, infos[2].textoff)
    end)
    it("open new window", function()
        vim.cmd.edit("spec/example.go")
        vim.diagnostic.set(test_ns, 0, diags)
        vim.cmd.normal("G")
        ui_update_all()
        assert.same(2, count_win())
        vim.cmd.wincmd("v")
        ui_update_all()
        assert.same(4, count_win())
        local fwins = vim.iter(vim.api.nvim_list_wins()):filter(win_is_float):totable()
        assert.same(2, #fwins)
        assert.same(6, vim.api.nvim_win_get_width(fwins[1]))
        assert.same(6, vim.api.nvim_win_get_width(fwins[2]))
    end)
end)
