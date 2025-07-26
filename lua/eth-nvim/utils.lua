local M = {}

function M.get_visual_selection()
  -- Try the register approach first (works when called from visual mode)
  local success, selection = pcall(function()
    -- Save the current register content
    local reg_save = vim.fn.getreg('"')
    local regtype_save = vim.fn.getregtype('"')
    
    -- Copy visual selection to default register
    vim.cmd('normal! gv"vy')
    
    -- Get the selected text
    local text = vim.fn.getreg('"')
    
    -- Restore the register
    vim.fn.setreg('"', reg_save, regtype_save)
    
    return text
  end)
  
  if success and selection and selection ~= "" then
    return selection
  end
  
  -- Fallback: use visual marks (works after exiting visual mode)
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  
  -- Check if marks are valid
  if start_pos[2] == 0 or end_pos[2] == 0 then
    return ""
  end

  local start_row, start_col = start_pos[2], start_pos[3]
  local end_row, end_col = end_pos[2], end_pos[3]

  if start_row == end_row then
    local line = vim.fn.getline(start_row)
    return string.sub(line, start_col, end_col)
  else
    local lines = vim.fn.getline(start_row, end_row)
    if #lines == 0 then
      return ""
    end

    lines[1] = string.sub(lines[1], start_col)
    lines[#lines] = string.sub(lines[#lines], 1, end_col)
    return table.concat(lines, "\n")
  end
end

function M.is_valid_ethereum_address(text)
  if not text then
    return false
  end

  text = text:gsub("%s+", "")

  if not text:match("^0x[a-fA-F0-9]+$") then
    return false
  end

  return #text == 42
end

function M.is_valid_transaction_hash(text)
  if not text then
    return false
  end

  text = text:gsub("%s+", "")

  if not text:match("^0x[a-fA-F0-9]+$") then
    return false
  end

  return #text == 66
end

function M.detect_ethereum_type(text)
  if not text then
    return nil
  end

  text = text:gsub("%s+", "")

  if M.is_valid_ethereum_address(text) then
    return "address"
  elseif M.is_valid_transaction_hash(text) then
    return "tx"
  end

  return nil
end

function M.normalize_ethereum_string(text)
  if not text then
    return nil
  end

  return text:gsub("%s+", ""):lower()
end

function M.open_url(url)
  local config = require("eth-nvim.config")
  local browser_cmd = config.get_browser_cmd()

  if not browser_cmd then
    vim.notify("No browser command available", vim.log.levels.ERROR)
    return false
  end

  local cmd = string.format("%s '%s'", browser_cmd, url)

  vim.fn.jobstart(cmd, {
    on_exit = function(_, exit_code)
      if exit_code ~= 0 then
        vim.notify(string.format("Failed to open URL: %s", url), vim.log.levels.ERROR)
      end
    end,
    detach = true,
  })

  return true
end

return M
