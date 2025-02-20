# 🧘 sense.nvim

Show diagnostics that are not visible in current view

## Requirements

- Neovim >= 0.10.2

## Installation

### rocks.nvim

```console
:Rocks install sense.nvim
```

### lazy.nvim

```lua
{
    "boltlessengineer/sense.nvim",
}
```

> [!NOTE]
> sense.nvim installs dependencies from luarocks.
> Check `:checkhealth lazy` if you have any troubles installing it's dependencies.
> In general, settting `.rocks.hererocks = true` in your [lazy.nvim] config should fix the issue. [^1]

## Configuration

You can configure sense.nvim with `vim.g.sense_nvim` global variable

### Example

```lua
vim.g.sense_nvim = {
    presets = {
        virtualtext = {
            max_width = 0.4,
        }
    }
}
```

### Default Configuration

<!-- default-config:start -->
```lua
---sense.nvim default configuration
---@class sense.Config
local default_config = {
    ---Preset components config
    ---@class sense.Config.Presets
    presets = {
        ---Config for diagnostic virtualtest component
        ---@class sense.Config.Presets.VirtualText
        virtualtext = {
            ---@type boolean enable diagnostic virtualtext component
            enabled = true,
            ---@type number max width of virtualtext component
            max_width = 0.5,
        },
        ---Config for diagnostic statuscolumn component
        ---@class sense.Config.Presets.StatusColumn
        statuscolumn = {
            ---@type boolean enable diagnostic statuscolumn component
            enabled = true,
        },
    },
    _log_level = vim.log.levels.WARN,
}
```
<!-- default-config:end -->

## Contributing

test drive plugin with nix:

```sh
nix run .#neovim-drive
```

[^1]: https://lazy.folke.io/configuration
