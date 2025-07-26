local M = {}

function M.setup_vim_mock()
  if not _G.vim then
    _G.vim = {
      fn = {
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
        has = function(feature)
          if feature == "unix" then
            return 1
          end
          return 0
        end,
      },
      log = {
        levels = {
          ERROR = 1,
          WARN = 2,
          INFO = 3,
          DEBUG = 4,
        },
      },
      notify = function() end,
      json = {
        encode = function(data)
          return require("dkjson").encode(data)
        end,
        decode = function(str)
          return require("dkjson").decode(str)
        end,
      },
      ui = {
        select = function() end,
      },
      keymap = {
        set = function() end,
      },
      tbl_deep_extend = function(behavior, ...)
        local result = {}
        local function merge(t)
          for k, v in pairs(t) do
            if type(v) == "table" and type(result[k]) == "table" then
              result[k] = vim.tbl_deep_extend(behavior, result[k], v)
            else
              result[k] = v
            end
          end
        end

        for _, t in ipairs({ ... }) do
          merge(t)
        end

        return result
      end,
    }
  end
end

return M
