---@module 'luassert'

require("spec.minimal_init")
local testutils = require("spec.testutils")

vim.g.sense_nvim = {
    presets = {
        virtualtext = {
            enabled = true,
        },
        statuscolumn = {
            enabled = false,
        },
    },
}

local TEST_NS = vim.api.nvim_create_namespace("sense.test")

describe("UI component - virtual", function()
    -- setup options to test with
    vim.o.number = true
    vim.o.relativenumber = true
    vim.o.signcolumn = "yes"
    vim.o.splitright = true
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

    before_each(function()
        -- clear all buffers/windows
        vim.cmd("silent! %bwipeout")
        vim.cmd("silent! wincmd o")

        -- open new buffer and set diagnostics
        testutils.open_file("spec/samples/error_at_top.go")
        vim.diagnostic.set(TEST_NS, 0, diags)
    end)
    it("assert vim window size", function()
        assert.same(vim.o.columns, 80)
        assert.same(vim.o.lines, 24)
    end)
    it("visible on scroll", function()
        assert.same(1, #testutils.list_visible_wins())

        -- go to bottom to show virtual UI pointing top
        vim.cmd.normal("G")
        testutils.emulate_missing_events("WinScrolled", {
            match = vim.api.nvim_get_current_win(),
        })
        assert.same(2, #testutils.list_visible_wins())
    end)
    it("with long message", function()
        vim.diagnostic.reset(TEST_NS, 0)
        vim.diagnostic.set(TEST_NS, 0, {
            {
                code = "UndeclaredName",
                col = 4,
                end_col = 7,
                end_lnum = 3,
                lnum = 3,
                message = "some really really long long long long message that easily exceeds 80 columns I need to put bit more text here to make it long enough",
                severity = 1,
                source = "compiler",
            },
        })
        vim.cmd.normal("G")
        testutils.emulate_missing_events("WinScrolled", {
            match = vim.api.nvim_get_current_win(),
        })
        assert.same(1, #testutils.list_visible_float_wins())
    end)
end)
