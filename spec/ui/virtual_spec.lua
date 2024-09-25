---@module 'luassert'

require("spec.minimal_init")
local ui = require("sense.ui")

---@diagnostic disable-next-line: duplicate-set-field
-- require("sense.log").debug = function (...)
--     vim.print(...)
-- end

-- describe("Test", function()
--     it("small test", function()
--         assert.same(3, 1 + 2)
--     end)
--     nio.tests.it("goplsssss", function ()
--         vim.cmd.edit("spec/example.go")
--         local buf = vim.api.nvim_get_current_buf()
--         assert.same("go", vim.bo[buf].filetype)
--         -- HACK: this is clearly not good way to wait until LspAttach event
--         nio.sleep(500)
--         local client = vim.lsp.get_clients({ bufnr = buf })[1]
--         assert.not_nil(client)
--         assert.same("gopls", client.name)
--     end)
--     it("open virtual window", function()
--     end)
-- end)

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
describe("UI component - virtual", function()
    local function count_win()
        return #vim.api.nvim_list_wins()
    end
    it("assert vim window size", function()
        assert.same(vim.o.columns, 80)
        assert.same(vim.o.lines, 24)
    end)
    it("open virtual window", function()
        vim.cmd.edit("spec/example.go")
        vim.diagnostic.set(test_ns, 0, diags)
        -- split window vertically
        vim.cmd.wincmd("v")
        assert.same(2, count_win())

        -- go to bottom to show virtual UI pointing top
        vim.cmd.normal("G")
        ui.update(vim.fn.getwininfo()[1])
        assert.same(3, count_win())

        -- close the new split window
        vim.cmd.wincmd("q")
        -- window count should be 1 here
        assert.same(1, count_win())
    end)
end)
