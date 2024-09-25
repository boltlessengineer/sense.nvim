---@module 'luassert'

require("spec.minimal_init")
local nio = require("nio")
local ui = require("sense.ui")

describe("Test", function()
    it("small test", function()
        assert.same(3, 1 + 2)
    end)
    nio.tests.it("goplsssss", function ()
        vim.cmd.edit("spec/example.go")
        local buf = vim.api.nvim_get_current_buf()
        assert.same("go", vim.bo[buf].filetype)
        -- HACK: this is clearly not good way to wait until LspAttach event
        nio.sleep(500)
        local client = vim.lsp.get_clients({ bufnr = buf })[1]
        assert.not_nil(client)
        assert.same("gopls", client.name)
    end)
    it("open virtual window", function()
    end)
end)

describe("UI", function ()
    nio.tests.it("open virtual window", function()
    end)
end)
