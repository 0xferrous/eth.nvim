local M = {}

-- Compute a nesting depth for a line from a Uniswap-style trace.
-- We treat each leading '│' as one level and a leading branch '├'/'└' as +1.
-- Lines without these box-drawing chars get depth 0.
local function strip_ansi(s)
  if not s or s == "" then
    return s
  end
  -- Strip common ANSI SGR sequences like ESC[31m, ESC[0;38;5;208m, etc.
  s = s:gsub("\27%[[0-9;]*m", "")
  -- Strip a broader class of CSI sequences (rough heuristic)
  s = s:gsub("\27%[[0-9;:%?]*[ -/]*[@-~]", "")
  return s
end

local function depth_from_prefix(line)
  if not line or line == "" then
    return 0
  end

  line = strip_ansi(line)
  -- Ignore any leading whitespace before the box-drawing prefix
  line = line:gsub("^%s+", "")
  -- Capture only the leading prefix composed of box-drawing chars and any interior spaces
  local prefix = line:match("^([│└├%s]+)") or ""

  -- Count vertical pipes in the prefix
  local pipes = 0
  if #prefix > 0 then
    local i = 1
    while true do
      local s, e = prefix:find("│", i, true)
      if not s then
        break
      end
      pipes = pipes + 1
      i = e + 1
    end
  end

  -- Add one level if this line is a branch in the tree (├ or └)
  local branch = (prefix:find("├", 1, true) or prefix:find("└", 1, true)) and 1 or 0

  return pipes + branch
end

function M.foldexpr(lnum)
  local line = vim.fn.getline(lnum)
  return depth_from_prefix(line)
end

-- Expose for tests: compute fold depth for a raw line
function M.depth_for_line(line)
  return depth_from_prefix(line)
end

-- Simple fold text: show the header line trimmed and how many lines are folded
function M.foldtext()
  local start_line = vim.fn.getline(vim.v.foldstart)
  local end_line = vim.fn.getline(vim.v.foldend)
  local count = vim.v.foldend - vim.v.foldstart + 1

  -- Trim leading box-drawing prefix for readability
  local header = strip_ansi(start_line):gsub("^[%s│└├─]+", "")
  local tail = end_line and strip_ansi(end_line):gsub("^[%s│└├─]+", "") or ""

  return string.format("%s … [%d lines] · %s", header, count, tail)
end

-- Enable expr-based folding for trace-like output in the current buffer
function M.enable(bufnr)
  bufnr = bufnr or 0
  vim.api.nvim_buf_set_option(bufnr, "foldmethod", "expr")
  vim.api.nvim_buf_set_option(bufnr, "foldexpr", "v:lua.require'eth-nvim.trace'.foldexpr(v:lnum)")
  vim.api.nvim_buf_set_option(bufnr, "foldtext", "v:lua.require'eth-nvim.trace'.foldtext()")
  -- Leave foldlevel/foldenable as-is so users can choose (zM/zR) behavior
  vim.notify("eth-nvim: trace folding enabled for this buffer")
end

-- Disable and reset to manual folding for the current buffer
function M.disable(bufnr)
  bufnr = bufnr or 0
  vim.api.nvim_buf_set_option(bufnr, "foldmethod", "manual")
  vim.api.nvim_buf_set_option(bufnr, "foldexpr", "0")
  vim.api.nvim_buf_set_option(bufnr, "foldtext", "")
  vim.notify("eth-nvim: trace folding disabled for this buffer")
end

return M
