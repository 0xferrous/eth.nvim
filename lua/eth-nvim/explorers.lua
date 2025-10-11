local M = {}

local config = require("eth-nvim.config")
local utils = require("eth-nvim.utils")
local frecency = require("eth-nvim.frecency")

function M.build_url(explorer, eth_value, eth_type)
  local template_key = eth_type == "address" and "address_url" or "tx_url"
  local template = explorer[template_key]

  if not template then
    return nil
  end

  local placeholder = eth_type == "address" and "{address}" or "{tx}"
  return template:gsub(placeholder, eth_value)
end

function M.show_explorer_menu(eth_value, eth_type)
  local explorers = config.get_explorers()
  local normalized_value = utils.normalize_ethereum_string(eth_value)

  if #explorers == 0 then
    vim.notify("No block explorers configured", vim.log.levels.WARN)
    return
  end

  if #explorers == 1 then
    frecency.record_usage(explorers[1].name)
    M.open_in_explorer(explorers[1], normalized_value, eth_type)
    return
  end

  local sorted_explorers = frecency.sort_explorers_by_frecency(explorers)

  local choices = {}
  for _i, explorer in ipairs(sorted_explorers) do
    table.insert(choices, string.format("%s", explorer.name))
  end

  vim.ui.select(choices, {
    prompt = string.format("Open %s (%s) in:", eth_type, normalized_value:sub(1, 10) .. "..."),
  }, function(choice, idx)
    if choice and idx then
      local selected_explorer = sorted_explorers[idx]
      frecency.record_usage(selected_explorer.name)
      M.open_in_explorer(selected_explorer, normalized_value, eth_type)
    end
  end)
end

function M.open_in_explorer(explorer, eth_value, eth_type)
  local url = M.build_url(explorer, eth_value, eth_type)

  if not url then
    vim.notify(
      string.format("No URL template for %s in %s", eth_type, explorer.name),
      vim.log.levels.ERROR
    )
    return
  end

  vim.notify(string.format("Opening %s in %s...", eth_type, explorer.name))

  if not utils.open_url(url) then
    vim.notify(string.format("Failed to open %s", url), vim.log.levels.ERROR)
  end
end

function M.add_explorer(name, address_url, tx_url)
  local explorers = config.get_explorers()

  local new_explorer = {
    name = name,
    address_url = address_url,
    tx_url = tx_url,
  }

  table.insert(explorers, new_explorer)
  config.options.explorers = explorers

  vim.notify(string.format("Added explorer: %s", name))
end

function M.remove_explorer(name)
  local explorers = config.get_explorers()

  for i, explorer in ipairs(explorers) do
    if explorer.name == name then
      table.remove(explorers, i)
      config.options.explorers = explorers
      vim.notify(string.format("Removed explorer: %s", name))
      return
    end
  end

  vim.notify(string.format("Explorer not found: %s", name), vim.log.levels.WARN)
end

return M
