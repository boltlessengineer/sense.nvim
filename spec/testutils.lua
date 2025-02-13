local M = {}

---@param path string filepath to open
---Open buffer and set content same as given path.
---
---This function is needed because `getwininfo()` has some weird behaviors when testing in nix
---sanxbox environment. It sometimes return `botline=0` while `topline=1`.
---There isn't any issue when tested locally (outside of nix build environment) but to be safe,
---we have this `open_file` function to simulate opening file in testing environment.
function M.open_file(path)
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {})
    for l in io.lines(path) do
        vim.api.nvim_buf_set_lines(0, -1, -1, false, { l })
    end
end

function M.list_visible_wins()
    return vim.api.nvim_tabpage_list_wins(0)
end

function M.list_visible_float_wins()
    return vim.iter(vim.api.nvim_tabpage_list_wins(0))
        :filter(function(win)
            local c = vim.api.nvim_win_get_config(win)
            return c.relative ~= ""
        end)
        :totable()
end

-- HACK: emulate missing events
-- TODO: use real neovim session instead (copy from neovim's internal testing module)
function M.emulate_missing_events(event, args)
    local autocmds = vim.api.nvim_get_autocmds({
        event = event,
    })
    vim.iter(autocmds):map(function(autocmd)
        if autocmd.callback then
            autocmd.callback(vim.tbl_extend("keep", args, {
                id = autocmd.id,
                group = autocmd.group,
                match = "",
                buf = vim.api.nvim_get_current_buf(),
                file = autocmd.file or autocmd.match or "",
            }))
        end
    end)
end

return M
