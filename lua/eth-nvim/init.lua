local M = {}

local config = require("eth-nvim.config")
local utils = require("eth-nvim.utils")
local explorers = require("eth-nvim.explorers")
local trace = require("eth-nvim.trace")

function M.setup(opts)
  config.setup(opts or {})
end

function M.explore_selection()
  local selection = utils.get_visual_selection()
  if not selection or selection == "" then
    vim.notify("No text selected", vim.log.levels.WARN)
    return
  end

  local eth_type = utils.detect_ethereum_type(selection)
  if not eth_type then
    vim.notify(
      "Selected text is not a valid Ethereum address or transaction hash",
      vim.log.levels.WARN
    )
    return
  end

  explorers.show_explorer_menu(selection, eth_type)
end

function M.show_config()
  config.show_current_config()
end

-- Public helpers to control trace folding programmatically
function M.enable_trace_folds()
  trace.enable(0)
end

function M.disable_trace_folds()
  trace.disable(0)
end

function M.toggle_trace_folds()
  local fm = vim.api.nvim_buf_get_option(0, "foldmethod")
  if fm == "expr" then
    trace.disable(0)
  else
    trace.enable(0)
  end
end

return M
