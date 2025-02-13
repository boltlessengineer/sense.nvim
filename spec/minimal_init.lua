vim.opt.runtimepath:append(assert(vim.env.SENSE_NVIM_PLUGIN_DIR))
vim.cmd("runtime! ftplugin.vim")
vim.cmd("runtime! ftdetect/*.{vim,lua}")
vim.cmd("runtime! filetype.lua")
vim.cmd("runtime! plugin/**/*.{vim,lua}")

local M = {}

function M.init_lsp()
    local servers = {
        gopls = {
            name = "gopls",
            cmd = { "gopls" },
            root_dir = vim.fs.root(0, { "go.work", "go.mod", "gotmpl", ".git" }),
            filetypes = { "go", "gomod", "gowork", "gotmpl" },
        },
    }
    local group = vim.api.nvim_create_augroup("UserLspStart", { clear = true })
    vim.api.nvim_create_autocmd("filetype", {
        group = group,
        pattern = servers.gopls.filetypes,
        callback = function(ev)
            vim.lsp.start(servers.gopls, {
                bufnr = ev.buf,
                reuse_client = function()
                    return true
                end,
            })
        end,
    })
end

return M
