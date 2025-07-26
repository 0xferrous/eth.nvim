# eth.nvim

A Neovim plugin for navigating Ethereum addresses and transaction hashes to various block explorers.

## Features

- 🔍 **Smart Detection**: Automatically detects Ethereum addresses and transaction hashes in visual selections
- 🌐 **Multiple Explorers**: Support for Etherscan, Arbiscan, Polygonscan, BSCScan, and custom explorers
- ⚙️ **Configurable**: Easy to configure with custom block explorers and URL templates
- 🚀 **Fast**: Lightweight Lua implementation with minimal overhead
- 🧪 **Well Tested**: Comprehensive test suite with high coverage

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "0xferrous/eth.nvim",
  config = function()
    require("eth-nvim").setup({
      -- your configuration here
    })
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "0xferrous/eth.nvim",
  config = function()
    require("eth-nvim").setup()
  end
}
```

## Usage

1. **Visual Selection**: Select an Ethereum address or transaction hash in visual mode
2. **Navigate**: Press `<leader>ee` (default) or run `:lua require('eth-nvim').explore_selection()`
3. **Choose Explorer**: Select from the configured block explorers
4. **Open**: The URL opens in your default browser

### Examples

Select any of these in visual mode and use `<leader>ee`:

- Address: `0x742d35cc6635c0532925a3b8d3ac25e0b7e4576c`
- Transaction: `0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef`

## Configuration

### Default Configuration

```lua
require("eth-nvim").setup({
  explorers = {
    {
      name = "Etherscan",
      address_url = "https://etherscan.io/address/{address}",
      tx_url = "https://etherscan.io/tx/{tx}",
    },
    {
      name = "Arbiscan",
      address_url = "https://arbiscan.io/address/{address}",
      tx_url = "https://arbiscan.io/tx/{tx}",
    },
    {
      name = "Polygonscan",
      address_url = "https://polygonscan.com/address/{address}",
      tx_url = "https://polygonscan.com/tx/{tx}",
    },
    {
      name = "BSCScan",
      address_url = "https://bscscan.com/address/{address}",
      tx_url = "https://bscscan.com/tx/{tx}",
    },
  },
  default_browser_cmd = nil, -- Auto-detect system browser
  keymaps = {
    explore = "<leader>ee",
  },
})
```

### Adding Custom Explorers

```lua
require("eth-nvim").setup({
  explorers = {
    {
      name = "Optimism",
      address_url = "https://optimistic.etherscan.io/address/{address}",
      tx_url = "https://optimistic.etherscan.io/tx/{tx}",
    },
    {
      name = "Gnosis",
      address_url = "https://gnosisscan.io/address/{address}",
      tx_url = "https://gnosisscan.io/tx/{tx}",
    },
    -- Add your custom explorers here
  },
})
```

### Custom Browser Command

```lua
require("eth-nvim").setup({
  default_browser_cmd = "firefox", -- or "google-chrome", "brave", etc.
})
```

### Custom Keymaps

```lua
require("eth-nvim").setup({
  keymaps = {
    explore = "<leader>eb", -- Change default keymap
  },
})
```

## Commands

- `:lua require('eth-nvim').explore_selection()` - Explore selected Ethereum address/tx
- `:lua require('eth-nvim').show_config()` - Show current configuration

## API

### Functions

- `require('eth-nvim').setup(opts)` - Setup plugin with options
- `require('eth-nvim').explore_selection()` - Explore current visual selection
- `require('eth-nvim').show_config()` - Display current configuration

### Utility Functions

- `require('eth-nvim.utils').is_valid_ethereum_address(text)` - Validate Ethereum address
- `require('eth-nvim.utils').is_valid_transaction_hash(text)` - Validate transaction hash
- `require('eth-nvim.utils').detect_ethereum_type(text)` - Detect if text is address or tx
- `require('eth-nvim.explorers').add_explorer(name, address_url, tx_url)` - Add explorer programmatically

## Development

This project uses Nix for development environment setup.

### Prerequisites

- [Nix](https://nixos.org/download.html) with flakes enabled

### Development Shell

```bash
nix develop
```

### Running Tests

```bash
nix develop --command busted
```

### Linting

```bash
nix develop --command luacheck lua/
```

### Formatting

```bash
nix develop --command stylua .
```

### Building

```bash
nix build
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Run tests and linting: `nix flake check`
6. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Supported Networks

The default configuration includes explorers for:

- **Ethereum** (Etherscan)
- **Arbitrum** (Arbiscan)  
- **Polygon** (Polygonscan)
- **BSC** (BSCScan)

You can easily add support for other networks by configuring custom explorers.