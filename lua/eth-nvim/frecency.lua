local M = {}

local function get_data_path()
  local data_path = vim.fn.stdpath("data")
  local plugin_data_dir = data_path .. "/eth-nvim"

  if vim.fn.isdirectory(plugin_data_dir) == 0 then
    vim.fn.mkdir(plugin_data_dir, "p")
  end

  return plugin_data_dir .. "/frecency.json"
end

local function get_current_directory()
  return vim.fn.getcwd()
end

local function normalize_directory_path(path)
  return vim.fn.fnamemodify(path, ":p:h")
end

local function load_frecency_data()
  local frecency_file = get_data_path()

  if vim.fn.filereadable(frecency_file) == 0 then
    return { global = {}, directories = {} }
  end

  local file = io.open(frecency_file, "r")
  if not file then
    return { global = {}, directories = {} }
  end

  local content = file:read("*a")
  file:close()

  if content == "" then
    return { global = {}, directories = {} }
  end

  local ok, data = pcall(vim.json.decode, content)
  if not ok then
    return { global = {}, directories = {} }
  end

  if not data.global then
    local legacy_data = data
    data = { global = legacy_data, directories = {} }
  end

  return data
end

local function save_frecency_data(data)
  local frecency_file = get_data_path()

  local file = io.open(frecency_file, "w")
  if not file then
    vim.notify("Failed to save frecency data", vim.log.levels.WARN)
    return
  end

  file:write(vim.json.encode(data))
  file:close()
end

local function record_usage_for_target(target_data, explorer_name, timestamp)
  if not target_data[explorer_name] then
    target_data[explorer_name] = {
      count = 0,
      last_used = 0,
      timestamps = {},
    }
  end

  target_data[explorer_name].count = target_data[explorer_name].count + 1
  target_data[explorer_name].last_used = timestamp

  table.insert(target_data[explorer_name].timestamps, timestamp)

  local max_timestamps = 20
  if #target_data[explorer_name].timestamps > max_timestamps then
    table.remove(target_data[explorer_name].timestamps, 1)
  end
end

function M.record_usage(explorer_name)
  local data = load_frecency_data()
  local timestamp = os.time()
  local current_dir = normalize_directory_path(get_current_directory())

  if not data.directories[current_dir] then
    data.directories[current_dir] = {}
  end

  record_usage_for_target(data.directories[current_dir], explorer_name, timestamp)
  record_usage_for_target(data.global, explorer_name, timestamp)

  save_frecency_data(data)
end

local function calculate_score_for_data(explorer_data, current_time)
  if not explorer_data then
    return 0
  end

  local frequency = explorer_data.count
  local recency_factor

  local time_since_last_use = current_time - explorer_data.last_used
  local one_day = 24 * 60 * 60
  local one_week = 7 * one_day
  local one_month = 30 * one_day

  if time_since_last_use < one_day then
    recency_factor = 4
  elseif time_since_last_use < one_week then
    recency_factor = 2
  elseif time_since_last_use < one_month then
    recency_factor = 1
  else
    recency_factor = 0.5
  end

  local recent_usage_bonus = 0
  if explorer_data.timestamps then
    local recent_threshold = current_time - (7 * one_day)
    for _, timestamp in ipairs(explorer_data.timestamps) do
      if timestamp > recent_threshold then
        recent_usage_bonus = recent_usage_bonus + 0.1
      end
    end
  end

  return (frequency * recency_factor) + recent_usage_bonus
end

function M.calculate_frecency_score(explorer_name)
  local data = load_frecency_data()
  local current_time = os.time()
  local current_dir = normalize_directory_path(get_current_directory())

  local directory_data = data.directories[current_dir]
  local directory_explorer_data = directory_data and directory_data[explorer_name]

  if directory_explorer_data then
    return calculate_score_for_data(directory_explorer_data, current_time)
  end

  local global_explorer_data = data.global[explorer_name]
  return calculate_score_for_data(global_explorer_data, current_time)
end

function M.sort_explorers_by_frecency(explorers)
  local explorer_scores = {}

  for i, explorer in ipairs(explorers) do
    local score = M.calculate_frecency_score(explorer.name)
    table.insert(explorer_scores, {
      explorer = explorer,
      score = score,
      original_index = i,
    })
  end

  table.sort(explorer_scores, function(a, b)
    if a.score == b.score then
      return a.original_index < b.original_index
    end
    return a.score > b.score
  end)

  local sorted_explorers = {}
  for _, item in ipairs(explorer_scores) do
    table.insert(sorted_explorers, item.explorer)
  end

  return sorted_explorers
end

return M
