local M = {}

local logger_level = vim.log.levels.DEBUG

local LOG_DATE_FORMAT = "%F %H:%M:%S"
local DEFAULT_LOG_PATH = vim.fn.stdpath("log") --[[@as string]]
local LARGE = 1e9

---Get the sense.nvim log file path.
---@return string filepath
local function get_logfile()
    return vim.fs.joinpath(DEFAULT_LOG_PATH, "sense-nvim.log")
end

local logfile, openerr
---@private
---Opens log file. Returns true if file is open, false on error
---@return boolean
local function open_logfile()
    -- Try to open file only once
    if logfile then
        return true
    end
    if openerr then
        return false
    end

    vim.fn.mkdir(DEFAULT_LOG_PATH, "-p")
    logfile, openerr = io.open(get_logfile(), "w+")
    if not logfile then
        local err_msg = string.format("Failed to open sense.nvim log file: %s", openerr)
        vim.notify(err_msg, vim.log.levels.ERROR, { title = "sense.nvim" })
        return false
    end

    ---@diagnostic disable-next-line: undefined-field
    local log_info = vim.uv.fs_stat(get_logfile())
    if log_info and log_info.size > LARGE then
        local warn_msg =
            string.format("sense.nvim log is large (%d MB): %s", log_info.size / (1000 * 1000), get_logfile())
        vim.notify(warn_msg, vim.log.levels.WARN, { title = "sense.nvim" })
    end

    -- Start message for logging
    logfile:write(string.format("[START][%s] sense.nvim logging initiated\n", os.date(LOG_DATE_FORMAT)))
    return true
end

function M.debug(...)
    if logger_level == vim.log.levels.OFF or not open_logfile() then
        return false
    end
    local argc = select("#", ...)
    if vim.log.levels.DEBUG < logger_level then
        return false
    end
    if argc == 0 then
        return true
    end
    local info = debug.getinfo(2, "Sl")
    local fileinfo = string.format("%s:%s", info.short_src, info.currentline)
    local parts = { "DEBUG", "|", os.date(LOG_DATE_FORMAT), "|", fileinfo, "|" }
    for i = 1, argc do
        local arg = select(i, ...)
        if arg == nil then
            table.insert(parts, "<nil>")
        elseif type(arg) == "string" then
            table.insert(parts, arg)
        else
            table.insert(parts, vim.inspect(arg))
        end
    end
    logfile:write(table.concat(parts, " "), "\n")
    logfile:flush()
end

return M
