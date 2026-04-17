# snacks-mk

A Neovim plugin for creating files and directories with ease, integrated with the Snacks picker system.

## Features

- **Directory Navigation**: Browse directories using `fd`/`fdfind` or `find` command
- **Batch Creation**: Create multiple files and directories at once using comma-separated input
- **Smart Filtering**: Automatically excludes common directories like `node_modules`, `build`, `dist`, etc.
- **Live Search**: Real-time directory filtering as you type
- **Intuitive Interface**: Simple command-based workflow

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "ChuYanLon/snacks-mk",
    lazy = true,
    cmd = { "CreateInDir" },
    dependencies = {
      "folke/snacks.nvim",
    },
    keys = {
      { "<leader>fn", "<cmd>CreateInDir<Cr>" },
    },
    config = function()
      require("snacks-mk").setup()
    end,
},
```

## Usage

### Basic Command

```vim
:CreateInDir
```

This command opens a directory picker. After selecting a directory, you'll be prompted to enter file/directory names to create.

### Creating Files and Directories

When prompted, you can create:
- **Files**: Enter filename (e.g., `main.lua`)
- **Directories**: Add trailing slash (e.g., `src/` or `lua/plugins/`)
- **Multiple items**: Separate with commas (e.g., `main.lua, src/, tests/`)

### Examples

```vim
:CreateInDir
# Select directory: ~/projects/my-app
# Prompt: Create (file or dir/): use "," to separate
# Input: main.lua, src/, tests/test_suite.lua
```

This creates:
- `~/projects/my-app/main.lua`
- `~/projects/my-app/src/` (directory)
- `~/projects/my-app/tests/test_suite.lua` (with parent directory `tests/`)

## Dependencies

- [snacks.nvim](https://github.com/anomalyco/snacks.nvim) - Required picker framework
- `fd` or `fdfind` (recommended) - Faster directory listing
- `find` (fallback) - Available on most Unix-like systems

## Requirements

- Neovim 0.9.0 or higher
- Snacks.nvim plugin installed

## License

MIT
