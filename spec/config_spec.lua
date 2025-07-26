describe("config", function()
  -- Setup vim mock inline for CI compatibility
  if not _G.vim then
    _G.vim = {
      fn = {
        has = function(feature) return feature == "unix" and 1 or 0 end,
        stdpath = function() return "/tmp" end,
        getcwd = function() return "/test/project" end,
        isdirectory = function() return 0 end,
        mkdir = function() return true end,
        filereadable = function() return 0 end,
        fnamemodify = function(path) return path end,
      },
      log = { levels = { ERROR = 1, WARN = 2, INFO = 3, DEBUG = 4 } },
      notify = function() end,
      keymap = { set = function() end },
      tbl_deep_extend = function(behavior, ...)
        local result = {}
        for _, tbl in ipairs({...}) do
          for k, v in pairs(tbl) do
            result[k] = v
          end
        end
        return result
      end,
    }
  end
  
  local config = require("eth-nvim.config")

  before_each(function()
    -- Reset config to defaults before each test
    config.options = {}
    config.setup()
  end)

  describe("setup", function()
    it("should use default configuration when no options provided", function()
      config.setup()
      local explorers = config.get_explorers()
      assert.is_true(#explorers > 0)
      assert.are.equal("Etherscan", explorers[1].name)
    end)

    it("should merge user options with defaults", function()
      config.setup({
        explorers = {
          {
            name = "CustomScan",
            address_url = "https://custom.io/address/{address}",
            tx_url = "https://custom.io/tx/{tx}",
          },
        },
      })

      local explorers = config.get_explorers()
      assert.are.equal(4, #explorers) -- tbl_deep_extend merges by index
      assert.are.equal("CustomScan", explorers[1].name) -- First is replaced
      assert.are.equal("Arbiscan", explorers[2].name) -- Rest are defaults
    end)

    it("should preserve default explorers when adding custom ones", function()
      -- Manually create a new array with defaults + custom
      local custom_explorers = {}
      for _, explorer in ipairs(config.defaults.explorers) do
        table.insert(custom_explorers, explorer)
      end
      table.insert(custom_explorers, {
        name = "CustomScan",
        address_url = "https://custom.io/address/{address}",
        tx_url = "https://custom.io/tx/{tx}",
      })

      config.setup({
        explorers = custom_explorers,
      })

      local explorers = config.get_explorers()
      assert.are.equal(5, #explorers) -- Should have 4 defaults + 1 custom
      assert.are.equal("CustomScan", explorers[#explorers].name)
    end)
  end)

  describe("get_browser_cmd", function()
    it("should return custom browser command when set", function()
      config.setup({
        default_browser_cmd = "firefox",
      })

      assert.are.equal("firefox", config.get_browser_cmd())
    end)

    it("should auto-detect browser command when not set", function()
      config.setup()
      local cmd = config.get_browser_cmd()
      -- Should return one of the system defaults or nil
      assert.is_true(cmd == "xdg-open" or cmd == "open" or cmd == "start" or cmd == nil)
    end)
  end)
end)
