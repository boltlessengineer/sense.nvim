---@module 'luassert'

vim.g.sense_nvim = {
    presets = {
        virtualtext = {
            enabled = false,
        },
        statuscolumn = {
            enabled = true,
        },
    },
}

require("spec.minimal_init")
local testutils = require("spec.testutils")

local TEST_NS = vim.api.nvim_create_namespace("sense.test")
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
    -- setup options to test with
    vim.o.number = true
    vim.o.relativenumber = true
    vim.o.signcolumn = "yes"
    vim.o.splitright = true
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
        assert.same(1, #testutils.list_visible_float_wins())
        assert.same(2, #testutils.list_visible_wins())
    end)
    it("split windows should work separately", function()
        assert.same(1, #testutils.list_visible_wins())

        -- split window vertically
        vim.cmd.wincmd("v")
        assert.same(2, #testutils.list_visible_wins())

        -- go to bottom to show virtual UI pointing top on new window
        vim.cmd.normal("G")
        testutils.emulate_missing_events("WinScrolled", {
            match = vim.api.nvim_get_current_win(),
        })
        assert.same(3, #testutils.list_visible_wins())

        -- close the new split window
        vim.cmd.wincmd("q")
        assert.same(1, #testutils.list_visible_wins())
    end)
    it("windows should have same state on vsplit", function()
        assert.same(1, #testutils.list_visible_wins())

        -- scroll to bottom (to reveal top-indicators)
        vim.cmd.normal("G")
        testutils.emulate_missing_events("WinScrolled", {
            match = vim.api.nvim_get_current_win(),
        })
        assert.same(2, #testutils.list_visible_wins())

        -- vertically split window
        vim.cmd.wincmd("v")
        local fwins = testutils.list_visible_float_wins()
        assert.same(2, #fwins)
        assert.same(6, vim.api.nvim_win_get_width(fwins[1]))
        assert.same(6, vim.api.nvim_win_get_width(fwins[2]))
        assert.same(4, #testutils.list_visible_wins())
    end)
    it("tabnew should hide all floating windows", function()
        assert.same(1, #testutils.list_visible_wins())

        -- scroll to bottom (to reveal top-indicators)
        vim.cmd.normal("G")
        testutils.emulate_missing_events("WinScrolled", {
            match = vim.api.nvim_get_current_win(),
        })
        assert.same(2, #testutils.list_visible_wins())

        -- open new tab
        vim.cmd.tabnew()
        local fwins = testutils.list_visible_float_wins()
        assert.same(0, #fwins)
        assert.same(1, #testutils.list_visible_wins())
    end)
end)

-- TODO: move out of here and automate it.
local ONELINE_DIAGS = {
    {
        bufnr = 1,
        col = 0,
        end_col = 0,
        end_lnum = 1,
        lnum = 1,
        message = "expected ';', found 'EOF'",
        namespace = 16,
        severity = 1,
        source = "syntax",
        user_data = {
            lsp = {
                message = "expected ';', found 'EOF'",
                range = {
                    ["end"] = {
                        character = 0,
                        line = 1,
                    },
                    start = {
                        character = 0,
                        line = 1,
                    },
                },
                severity = 1,
                source = "syntax",
            },
        },
    },
}

describe("samples/oneline.go", function()
    before_each(function()
        -- clear all buffers/windows
        vim.cmd("silent! %bwipeout")
        vim.cmd("silent! wincmd o")
    end)
    it("when buffer height is smaller than window height", function()
        -- open new buffer and set diagnostics
        testutils.open_file("spec/samples/oneline.go")
        vim.diagnostic.set(TEST_NS, 0, ONELINE_DIAGS)
        assert.same(0, #testutils.list_visible_float_wins())
    end)
end)
