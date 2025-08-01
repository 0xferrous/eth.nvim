local M = {}

function M.setup()
  _G.vim = {
    tbl_deep_extend = function(behavior, ...)
      local result = {}
      local function deep_extend(target, source)
        for k, v in pairs(source) do
          if type(v) == "table" and type(target[k]) == "table" then
            target[k] = deep_extend(target[k], v)
          else
            target[k] = v
          end
        end
        return target
      end

      for _, tbl in ipairs({ ... }) do
        result = deep_extend(result, tbl)
      end
      return result
    end,

    keymap = {
      set = function(mode, lhs, rhs, opts)
        -- Mock keymap setting
      end,
    },

    notify = function(msg, level)
      -- Mock notification
      print(string.format("[%s] %s", level or "INFO", msg))
    end,

    log = {
      levels = {
        DEBUG = 0,
        INFO = 1,
        WARN = 2,
        ERROR = 3,
      },
    },

    fn = {
      has = function(feature)
        if feature == "unix" then
          return 1
        end
        return 0
      end,

      getpos = function(mark)
        -- Mock position
        return { 0, 1, 1, 0 }
      end,

      getline = function(start, finish)
        if finish then
          return { "0x742d35cc6635c0532925a3b8d3ac25e0b7e4576c" }
        else
          return "0x742d35cc6635c0532925a3b8d3ac25e0b7e4576c"
        end
      end,

      jobstart = function(cmd, opts)
        return 1
      end,

      stdpath = function(type)
        if type == "data" then
          return "/tmp"
        end
        return "/tmp"
      end,

      getcwd = function()
        return "/test/project"
      end,

      isdirectory = function(path)
        return 0
      end,

      mkdir = function(path, mode)
        return true
      end,

      filereadable = function(path)
        if path and path:match("/tmp/eth%-nvim/frecency%.json") then
          local file = io.open(path, "r")
          if file then
            file:close()
            return 1
          end
        end
        return 0
      end,

      fnamemodify = function(path, modifier)
        if modifier == ":p:h" then
          return path
        end
        return path
      end,
    },

    json = {
      encode = function(data)
        return require("dkjson").encode(data)
      end,
      decode = function(str)
        return require("dkjson").decode(str)
      end,
    },

    ui = {
      select = function(choices, opts, callback)
        -- Mock selection - choose first option
        if #choices > 0 then
          callback(choices[1], 1)
        end
      end,
    },
  }
end

function M.teardown()
  _G.vim = nil
end

return M
