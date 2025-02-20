# 🧘 sense.nvim

sense.nvim shows diagnostics that are not visible in current view with their distance.\
Allows you to quickly navigate to off-screen diagnostics with relative-line-number motions.\
Don't miss the diagnostics ever again!

<https://github.com/user-attachments/assets/25ee8ece-855a-41cb-8000-84e26613e849>

## Requirements

- Neovim >= 0.10.2
- rockspec support enabled in your Neovim plugin manager (See [Installation](#installation))

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

Contributions are always welcome!

> [!IMPORTANT]
>
> sense.nvim uses [semantic commits](https://www.conventionalcommits.org/en/v1.0.0/) that adhere to
> semantic versioning and these help with automatic releases, please use this type of convention
> when submitting changes to the project.

You can test drive the plugin with nix:

```console
nix run .#neovim-with-sense
```

### Dev Environment

You can enter devshell as nix shell.

```console
nix develop
```

[^1]: https://lazy.folke.io/configuration
