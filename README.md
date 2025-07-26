# eth.nvim

A Neovim plugin for navigating Ethereum addresses and transaction hashes to various block explorers.

## Features

- 🔍 **Smart Detection**: Automatically detects Ethereum addresses and transaction hashes in visual selections
- 🌐 **Multiple Explorers**: Support for Etherscan, Arbiscan, Polygonscan, BSCScan, and custom explorers
- 🧠 **Frecency Ordering**: Smart ordering of explorer options based on frequency and recency of use
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
3. **Choose Explorer**: Select from the configured block explorers (ordered by frecency)
4. **Open**: The URL opens in your default browser

### Frecency-Based Ordering

The plugin automatically learns your preferences and orders explorer options based on **frecency** - a combination of frequency and recency:

- **Frequently used explorers** appear higher in the list
- **Recently used explorers** get priority over older selections
- **Per-directory tracking** adapts to project-specific network preferences
- **Global fallback** ensures consistent ordering across all projects
- **Decay over time** ensures the ordering stays relevant to current usage patterns

The frecency system tracks:
- **Usage count**: How often you select each explorer
- **Last used timestamp**: When you last used each explorer  
- **Recent activity**: Additional weight for explorers used in the past week
- **Directory context**: Separate tracking per project directory
- **Time-based decay**: Reduces priority for explorers not used recently

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

## Frecency Implementation

The frecency system combines frequency and recency to intelligently order explorer options:

### Algorithm Details

**Frecency Score = (Usage Count × Recency Factor) + Recent Usage Bonus**

Where:
- **Usage Count**: Total number of times an explorer has been selected
- **Recency Factor**: Time-based multiplier applied based on last usage:
  - Used < 1 day ago: 4x multiplier
  - Used < 1 week ago: 2x multiplier  
  - Used < 1 month ago: 1x multiplier
  - Used > 1 month ago: 0.5x multiplier
- **Recent Usage Bonus**: +0.1 for each usage within the past week

### Data Storage

Usage data is stored in `~/.local/share/nvim/eth-nvim/frecency.json` with per-directory tracking:

```json
{
  "global": {
    "Etherscan": {
      "count": 15,
      "last_used": 1703123456,
      "timestamps": [1703123456, 1703109876, ...]
    },
    "Arbiscan": {
      "count": 8,
      "last_used": 1703000000,
      "timestamps": [1703000000, 1702999876, ...]
    }
  },
  "directories": {
    "/home/user/defi-project": {
      "Etherscan": {
        "count": 10,
        "last_used": 1703123456,
        "timestamps": [1703123456, ...]
      },
      "Polygonscan": {
        "count": 5,
        "last_used": 1703100000,
        "timestamps": [1703100000, ...]
      }
    },
    "/home/user/layer2-project": {
      "Arbiscan": {
        "count": 12,
        "last_used": 1703120000,
        "timestamps": [1703120000, ...]
      }
    }
  }
}
```

### Privacy & Performance

- Only the last 20 timestamps are stored per explorer to limit data growth
- No sensitive information (addresses, transactions) is stored
- Data persists across Neovim sessions
- Per-directory tracking adapts to project-specific network usage
- Automatic fallback to global data when no directory-specific data exists
- Automatic fallback to original order for new/unused explorers
- Legacy data format automatically migrated to new per-directory structure