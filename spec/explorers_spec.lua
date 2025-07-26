describe("explorers", function()
  local explorers = require("eth-nvim.explorers")

  describe("build_url", function()
    local test_explorer = {
      name = "TestScan",
      address_url = "https://testscan.io/address/{address}",
      tx_url = "https://testscan.io/tx/{tx}",
    }

    it("should build address URLs correctly", function()
      local url =
        explorers.build_url(test_explorer, "0x742d35cc6635c0532925a3b8d3ac25e0b7e4576c", "address")
      assert.are.equal(
        "https://testscan.io/address/0x742d35cc6635c0532925a3b8d3ac25e0b7e4576c",
        url
      )
    end)

    it("should build transaction URLs correctly", function()
      local url = explorers.build_url(
        test_explorer,
        "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
        "tx"
      )
      assert.are.equal(
        "https://testscan.io/tx/0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
        url
      )
    end)

    it("should return nil for missing template", function()
      local incomplete_explorer = {
        name = "Incomplete",
        address_url = "https://incomplete.io/address/{address}",
      }
      local url = explorers.build_url(
        incomplete_explorer,
        "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
        "tx"
      )
      assert.is_nil(url)
    end)

    it("should handle multiple placeholders", function()
      local custom_explorer = {
        name = "Custom",
        address_url = "https://custom.io/{address}/info?address={address}",
        tx_url = "https://custom.io/{tx}/details?tx={tx}",
      }

      local addr_url = explorers.build_url(
        custom_explorer,
        "0x742d35cc6635c0532925a3b8d3ac25e0b7e4576c",
        "address"
      )
      assert.are.equal(
        "https://custom.io/0x742d35cc6635c0532925a3b8d3ac25e0b7e4576c/info?address=0x742d35cc6635c0532925a3b8d3ac25e0b7e4576c",
        addr_url
      )

      local tx_url = explorers.build_url(
        custom_explorer,
        "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
        "tx"
      )
      assert.are.equal(
        "https://custom.io/0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef/details?tx=0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
        tx_url
      )
    end)
  end)
end)
