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

---@param path string filepath to open
---Open buffer and set content same as given path.
---
---This function is needed because `getwininfo()` has some weird behaviors when testing in nix
---sanxbox environment. It sometimes return `botline=0` while `topline=1`.
---There isn't any issue when tested locally (outside of nix build environment) but to be safe,
---we have this `open_file` function to simulate opening file in testing environment.
local function open_file(path)
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
    for l in io.lines(path) do
        vim.api.nvim_buf_set_lines(0, -1, -1, false, { l })
    end
end

describe("UI component - statuscol", function()
    local function count_visible_win()
        return #vim.api.nvim_tabpage_list_wins(0)
    end
    local function win_is_float(win)
        local c = vim.api.nvim_win_get_config(win)
        return c.relative ~= ""
    end
    local function ui_update_all()
        vim.iter(vim.fn.getwininfo()):map(ui.update)
    end
    -- setup options to test with
    vim.o.number = true
    vim.o.relativenumber = true
    vim.o.signcolumn = "yes"
    vim.o.splitright = true
    before_each(function()
        -- clear all buffers/windows
        vim.cmd("silent! %bwipeout")
        vim.cmd("silent! wincmd o")
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
    it("vsplit windows should have same state", function()
        -- open new buffer and set diagnostics
        open_file("spec/example.go")
        vim.diagnostic.set(test_ns, 0, diags)
        assert.same(1, count_visible_win())

        -- scroll to bottom (to reveal top-indicators)
        vim.cmd.normal("G")
        ui_update_all()
        assert.same(2, count_visible_win())

        -- vertically split window
        vim.cmd.wincmd("v")
        ui_update_all()
        assert.same(4, count_visible_win())
        local fwins = vim.iter(vim.api.nvim_tabpage_list_wins(0)):filter(win_is_float):totable()
        assert.same(2, #fwins)
        assert.same(6, vim.api.nvim_win_get_width(fwins[1]))
        assert.same(6, vim.api.nvim_win_get_width(fwins[2]))
    end)
    it("tabnew should hide all floating windows", function()
        -- open new buffer and set diagnostics
        open_file("spec/example.go")
        vim.diagnostic.set(test_ns, 0, diags)
        assert.same(1, count_visible_win())

        -- scroll to bottom (to reveal top-indicators)
        vim.cmd.normal("G")
        ui_update_all()
        assert.same(2, count_visible_win())

        -- open new tab
        vim.cmd.tabnew()
        -- ui_update_all()
        local fwins = vim.iter(vim.api.nvim_tabpage_list_wins(0)):filter(win_is_float):totable()
        assert.same(0, #fwins)
        assert.same(1, count_visible_win())
    end)
end)
