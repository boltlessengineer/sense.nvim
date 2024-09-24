---@module 'luassert'

describe("Test", function ()
    it("small test", function()
        assert.same(2, 1 + 1)
    end)
    it("can I use gopls?", function ()
        vim.cmd.edit("spec/example.go")
        local buf = vim.api.nvim_get_current_buf()
        local clients = vim.lsp.get_clients({ bufnr = buf })
        assert.same(1, #clients)
    end)
end)
