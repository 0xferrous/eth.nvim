describe("frecency", function()
  local frecency = require("eth-nvim.frecency")

  local test_data_path = "/tmp/eth-nvim-test-frecency.json"
  local original_stdpath, original_getcwd

  before_each(function()
    -- Store original functions
    original_stdpath = vim.fn.stdpath
    original_getcwd = vim.fn.getcwd

    -- Set up test environment
    vim.fn.stdpath = function(type)
      if type == "data" then
        return "/tmp"
      end
      return original_stdpath(type)
    end

    vim.fn.getcwd = function()
      return "/test/project"
    end

    -- Ensure directory exists and clear test files
    os.execute("mkdir -p /tmp/eth-nvim")

    -- Clear frecency file
    local file = io.open("/tmp/eth-nvim/frecency.json", "w")
    if file then
      file:write("")
      file:close()
    end

    -- Clear test data file
    local file = io.open(test_data_path, "w")
    if file then
      file:write("")
      file:close()
    end
  end)

  after_each(function()
    vim.fn.stdpath = original_stdpath
    vim.fn.getcwd = original_getcwd

    -- Clean up frecency file
    local file = io.open("/tmp/eth-nvim/frecency.json", "w")
    if file then
      file:write("")
      file:close()
    end

    local file = io.open(test_data_path, "w")
    if file then
      file:write("")
      file:close()
    end
  end)

  describe("per-directory frecency tracking", function()
    it("should track usage separately per directory", function()
      -- Project1: Use Etherscan heavily, Polygonscan lightly
      vim.fn.getcwd = function()
        return "/project1"
      end
      for i = 1, 10 do
        frecency.record_usage("Etherscan")
      end
      frecency.record_usage("Polygonscan")

      -- Project2: Use Polygonscan heavily, Etherscan lightly
      vim.fn.getcwd = function()
        return "/project2"
      end
      for i = 1, 10 do
        frecency.record_usage("Polygonscan")
      end
      frecency.record_usage("Etherscan")

      -- In project1: Etherscan (10 directory) > Polygonscan (1 directory)
      vim.fn.getcwd = function()
        return "/project1"
      end
      local p1_etherscan = frecency.calculate_frecency_score("Etherscan")
      local p1_polygonscan = frecency.calculate_frecency_score("Polygonscan")

      assert.is_true(p1_etherscan > p1_polygonscan, "In project1, Etherscan should score higher")

      -- In project2: Polygonscan (10 directory) > Etherscan (1 directory)
      vim.fn.getcwd = function()
        return "/project2"
      end
      local p2_etherscan = frecency.calculate_frecency_score("Etherscan")
      local p2_polygonscan = frecency.calculate_frecency_score("Polygonscan")

      assert.is_true(p2_polygonscan > p2_etherscan, "In project2, Polygonscan should score higher")
    end)

    it("should fallback to global data when no directory data exists", function()
      vim.fn.getcwd = function()
        return "/old/project"
      end
      frecency.record_usage("Polygonscan")
      frecency.record_usage("Polygonscan")
      frecency.record_usage("Polygonscan")

      vim.fn.getcwd = function()
        return "/new/project"
      end
      local score = frecency.calculate_frecency_score("Polygonscan")

      assert.is_true(score > 0, "Should fallback to global frecency data")
    end)

    it("should use directory data when available, global when not", function()
      -- Create directory-specific usage that's different from global
      vim.fn.getcwd = function()
        return "/specific/project"
      end

      -- Record minimal usage for BSCScan in this directory
      frecency.record_usage("BSCScan")

      -- Record usage in another directory to create different global data
      vim.fn.getcwd = function()
        return "/other/project"
      end
      for i = 1, 5 do
        frecency.record_usage("BSCScan")
      end

      -- Test that specific directory uses its own data (count=1, score=4.1)
      vim.fn.getcwd = function()
        return "/specific/project"
      end
      local specific_score = frecency.calculate_frecency_score("BSCScan")

      -- Test that new directory falls back to global data (count=6, score=24.6)
      vim.fn.getcwd = function()
        return "/new/project"
      end
      local global_fallback_score = frecency.calculate_frecency_score("BSCScan")

      -- Global fallback should be much higher since it has more total usage
      assert.is_true(
        global_fallback_score > specific_score,
        "Global fallback should reflect total usage across all directories"
      )

      -- Verify scores are in expected ranges
      assert.is_true(
        specific_score >= 4 and specific_score < 5,
        "Directory-specific score should be around 4.1"
      )
      assert.is_true(global_fallback_score >= 24, "Global fallback score should be around 24.6")
    end)

    it("should sort explorers by frecency per directory", function()
      vim.fn.getcwd = function()
        return "/defi/project"
      end
      frecency.record_usage("Etherscan")
      frecency.record_usage("Etherscan")
      frecency.record_usage("Etherscan")
      frecency.record_usage("Polygonscan")

      local explorers = {
        { name = "Etherscan" },
        { name = "Arbiscan" },
        { name = "Polygonscan" },
        { name = "BSCScan" },
      }

      local sorted = frecency.sort_explorers_by_frecency(explorers)

      assert.are.equal("Etherscan", sorted[1].name, "Etherscan should be first")
      assert.are.equal("Polygonscan", sorted[2].name, "Polygonscan should be second")
    end)

    it("should handle legacy data format migration", function()
      local legacy_data = {
        ["Etherscan"] = {
          count = 5,
          last_used = os.time() - 3600,
          timestamps = { os.time() - 3600 },
        },
      }

      -- Write legacy data to the actual frecency file
      local file = io.open("/tmp/eth-nvim/frecency.json", "w")
      file:write(vim.json.encode(legacy_data))
      file:close()

      vim.fn.getcwd = function()
        return "/any/project"
      end
      local score = frecency.calculate_frecency_score("Etherscan")

      assert.is_true(score > 0, "Should migrate legacy data correctly")
    end)

    it("should maintain both directory and global tracking", function()
      vim.fn.getcwd = function()
        return "/test/dir"
      end
      frecency.record_usage("Etherscan")

      -- Read from the actual frecency file
      local file = io.open("/tmp/eth-nvim/frecency.json", "r")
      local content = file:read("*a")
      file:close()

      assert.is_true(content ~= "", "File should have content")

      local data = vim.json.decode(content)
      assert.is_not_nil(data, "Should be able to decode JSON")

      assert.is_not_nil(data.global, "Should have global data")
      assert.is_not_nil(data.directories, "Should have directories data")
      assert.is_not_nil(data.global["Etherscan"], "Should track globally")
      assert.is_not_nil(data.directories["/test/dir"]["Etherscan"], "Should track per directory")
    end)
  end)

  describe("frecency scoring", function()
    it("should calculate recency factors correctly", function()
      local current_time = os.time()

      vim.fn.getcwd = function()
        return "/test/recent"
      end
      frecency.record_usage("RecentExplorer")

      local score = frecency.calculate_frecency_score("RecentExplorer")
      assert.is_true(score >= 4, "Recent usage should have high recency factor")
    end)

    it("should add recent usage bonus", function()
      vim.fn.getcwd = function()
        return "/test/bonus"
      end

      for i = 1, 5 do
        frecency.record_usage("BonusExplorer")
      end

      local score = frecency.calculate_frecency_score("BonusExplorer")
      assert.is_true(score >= 5.5, "Should include recent usage bonus")
    end)
  end)
end)
