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

## Contributing

test drive plugin with nix:

```sh
nix run .#neovim-drive
```

[^1]: https://lazy.folke.io/configuration
