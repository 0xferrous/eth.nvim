describe("utils", function()
  local utils = require("eth-nvim.utils")

  describe("is_valid_ethereum_address", function()
    it("should validate correct Ethereum addresses", function()
      assert.is_true(utils.is_valid_ethereum_address("0x742d35cc6635c0532925a3b8d3ac25e0b7e4576c"))
      assert.is_true(utils.is_valid_ethereum_address("0x742d35Cc6635C0532925a3b8D3Ac25e0b7E4576c"))
      assert.is_true(utils.is_valid_ethereum_address("0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045"))
    end)

    it("should reject invalid Ethereum addresses", function()
      assert.is_false(utils.is_valid_ethereum_address("0x742d35cc6635c0532925a3b8d3ac25e0b7e4576")) -- too short
      assert.is_false(
        utils.is_valid_ethereum_address("0x742d35cc6635c0532925a3b8d3ac25e0b7e4576cc")
      ) -- too long
      assert.is_false(utils.is_valid_ethereum_address("742d35cc6635c0532925a3b8d3ac25e0b7e4576c")) -- no 0x prefix
      assert.is_false(utils.is_valid_ethereum_address("0xg42d35cc6635c0532925a3b8d3ac25e0b7e4576c")) -- invalid character
      assert.is_false(utils.is_valid_ethereum_address(""))
      assert.is_false(utils.is_valid_ethereum_address(nil))
    end)

    it("should handle whitespace", function()
      assert.is_true(
        utils.is_valid_ethereum_address(" 0x742d35cc6635c0532925a3b8d3ac25e0b7e4576c ")
      )
      assert.is_true(
        utils.is_valid_ethereum_address("0x742d35cc6635c0532925a3b8d3ac25e0b7e4576c\n")
      )
    end)
  end)

  describe("is_valid_transaction_hash", function()
    it("should validate correct transaction hashes", function()
      assert.is_true(
        utils.is_valid_transaction_hash(
          "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
        )
      )
      assert.is_true(
        utils.is_valid_transaction_hash(
          "0x1234567890ABCDEF1234567890ABCDEF1234567890ABCDEF1234567890ABCDEF"
        )
      )
    end)

    it("should reject invalid transaction hashes", function()
      assert.is_false(
        utils.is_valid_transaction_hash(
          "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcde"
        )
      ) -- too short
      assert.is_false(
        utils.is_valid_transaction_hash(
          "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdeff"
        )
      ) -- too long
      assert.is_false(
        utils.is_valid_transaction_hash(
          "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
        )
      ) -- no 0x prefix
      assert.is_false(
        utils.is_valid_transaction_hash(
          "0xg234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
        )
      ) -- invalid character
      assert.is_false(utils.is_valid_transaction_hash(""))
      assert.is_false(utils.is_valid_transaction_hash(nil))
    end)

    it("should handle whitespace", function()
      assert.is_true(
        utils.is_valid_transaction_hash(
          " 0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef "
        )
      )
      assert.is_true(
        utils.is_valid_transaction_hash(
          "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef\n"
        )
      )
    end)
  end)

  describe("detect_ethereum_type", function()
    it("should detect addresses", function()
      assert.are.equal(
        "address",
        utils.detect_ethereum_type("0x742d35cc6635c0532925a3b8d3ac25e0b7e4576c")
      )
    end)

    it("should detect transaction hashes", function()
      assert.are.equal(
        "tx",
        utils.detect_ethereum_type(
          "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
        )
      )
    end)

    it("should return nil for invalid input", function()
      assert.is_nil(utils.detect_ethereum_type("invalid"))
      assert.is_nil(utils.detect_ethereum_type(""))
      assert.is_nil(utils.detect_ethereum_type(nil))
    end)
  end)

  describe("normalize_ethereum_string", function()
    it("should remove whitespace and convert to lowercase", function()
      assert.are.equal(
        "0x742d35cc6635c0532925a3b8d3ac25e0b7e4576c",
        utils.normalize_ethereum_string(" 0x742d35Cc6635C0532925a3b8D3Ac25e0b7E4576c ")
      )
      assert.are.equal(
        "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
        utils.normalize_ethereum_string(
          "0x1234567890ABCDEF1234567890ABCDEF1234567890ABCDEF1234567890ABCDEF\n"
        )
      )
    end)

    it("should handle nil input", function()
      assert.is_nil(utils.normalize_ethereum_string(nil))
    end)
  end)
end)
