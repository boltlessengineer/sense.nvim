---@diagnostic disable: lowercase-global
local _MODREV, _SPECREV = "scm", "-1"
rockspec_format = "3.0"
package = "sense.nvim"
version = _MODREV .. _SPECREV

dependencies = {
    "luautf8",
}

test_dependencies = {
    "lua >= 5.1",
    "nlua",
}

source = {
    url = "git://github.com/boltlessengineer/" .. package,
}

build = {
    type = "builtin",
    copy_directories = {
        "plugin",
    }
}
