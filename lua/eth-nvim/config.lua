local M = {}

M.defaults = {
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
  default_browser_cmd = nil, -- Will use system default
  keymaps = {
    explore = "<leader>ee",
  },
}

M.options = {}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})

  -- Set up keymaps
  if M.options.keymaps.explore then
    vim.keymap.set(
      "v",
      M.options.keymaps.explore,
      ":<C-u>lua require('eth-nvim').explore_selection()<CR>",
      { desc = "Explore Ethereum address/tx in block explorer" }
    )
  end
end

function M.get_explorers()
  return M.options.explorers or M.defaults.explorers
end

function M.get_browser_cmd()
  if M.options.default_browser_cmd then
    return M.options.default_browser_cmd
  end

  -- Auto-detect system browser command
  if vim.fn.has("mac") == 1 then
    return "open"
  elseif vim.fn.has("unix") == 1 then
    return "xdg-open"
  elseif vim.fn.has("win32") == 1 then
    return "start"
  end

  return nil
end

function M.show_current_config()
  local lines = {
    "Current eth-nvim configuration:",
    "",
    "Explorers:",
  }

  for i, explorer in ipairs(M.get_explorers()) do
    table.insert(lines, string.format("  %d. %s", i, explorer.name))
    table.insert(lines, string.format("     Address: %s", explorer.address_url))
    table.insert(lines, string.format("     TX: %s", explorer.tx_url))
    table.insert(lines, "")
  end

  table.insert(lines, string.format("Browser command: %s", M.get_browser_cmd() or "auto-detect"))
  table.insert(lines, string.format("Keymap: %s", M.options.keymaps.explore or "none"))

  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end

return M
