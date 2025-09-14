local trace = require("eth-nvim.trace")

describe("trace.depth_for_line", function()
  it("returns 0 for empty or plain lines", function()
    assert.are.equal(0, trace.depth_for_line(""))
    assert.are.equal(0, trace.depth_for_line(nil))
    assert.are.equal(0, trace.depth_for_line("[108428] SwapRouter::exactOutputSingle(...)"))
  end)

  it("counts pipes as nesting", function()
    assert.are.equal(1, trace.depth_for_line("│ UniswapV3Pool::swap(...)"))
    assert.are.equal(2, trace.depth_for_line("│ │ UniswapV3Pool::swap(...)"))
    assert.are.equal(3, trace.depth_for_line("│ │ │ UniswapV3Pool::swap(...)"))
  end)

  it("adds one for branch markers", function()
    assert.are.equal(
      1,
      trace.depth_for_line("├─ [20300] TransparentUpgradeableProxy::fallback(...)")
    )
    assert.are.equal(
      2,
      trace.depth_for_line("│ ├─ [20300] TransparentUpgradeableProxy::fallback(...)")
    )
    assert.are.equal(
      3,
      trace.depth_for_line("│ │ ├─ [20300] TransparentUpgradeableProxy::fallback(...)")
    )
    assert.are.equal(2, trace.depth_for_line("│ └─ [1250] FiatTokenProxy::fallback(...)"))
  end)

  it("handles leading spaces", function()
    assert.are.equal(1, trace.depth_for_line("  ├─ aeWETH::transfer(...)"))
    assert.are.equal(0, trace.depth_for_line("   not a trace line"))
  end)

  it("ignores ANSI escape codes", function()
    local red = "\27[31m"
    local reset = "\27[0m"
    assert.are.equal(
      2,
      trace.depth_for_line(red .. "│ " .. reset .. "├─ FiatTokenProxy::fallback(...)")
    )
    assert.are.equal(
      1,
      trace.depth_for_line(red .. "├─" .. reset .. " FiatTokenProxy::fallback(...)")
    )
  end)
end)

describe("trace.depth_for_line on full sample trace", function()
  local sample = [[
 [[
  [108428] SwapRouter::exactOutputSingle(ExactOutputSingleParams({ tokenIn: 0xaf88d065e77c8cC2239327C5EDb3A432268e5831, tokenOut: 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1, fee: 500, recipient: 0x8c19E9AD4D2c3db1a0966b1b91DE325274E233cf, deadline: 1757850489 [1.757e9], amountOut: 323327000000000000 [3.233e17], amountInMaximum: 1500290901 [1.5e9], sqrtPriceLimitX96: 0 }))
    ├─ [100745] UniswapV3Pool::swap(0x8c19E9AD4D2c3db1a0966b1b91DE325274E233cf, false, -323327000000000000 [-3.233e17], 1461446703485210103287273052203988822378723970341 [1.461e48], 0x000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000400000000000000000000000008c19e9ad4d2c3db1a0966b1b91de325274e233cf000000000000000000000000000000000000000000000000000000000000002b82af49447d8a07e3bd95bd0d56f35241523fbab10001f4af88d065e77c8cc2239327c5edb3a432268e5831000000000000000000000000000000000000000000)
    │   ├─ [20300] TransparentUpgradeableProxy::fallback(0x8c19E9AD4D2c3db1a0966b1b91DE325274E233cf, 323327000000000000 [3.233e17])
    │   │   ├─ [13054] aeWETH::transfer(0x8c19E9AD4D2c3db1a0966b1b91DE325274E233cf, 323327000000000000 [3.233e17]) [delegatecall]
    │   │   │   ├─ emit Transfer(from: UniswapV3Pool: [0xC6962004f452bE9203591991D15f6b388e09E8D0], to: 0x8c19E9AD4D2c3db1a0966b1b91DE325274E233cf, value: 323327000000000000 [3.233e17])
    │   │   │   └─ ← [Return] true
    │   │   └─ ← [Return] true
    │   ├─ [9750] FiatTokenProxy::fallback(UniswapV3Pool: [0xC6962004f452bE9203591991D15f6b388e09E8D0]) [staticcall]
    │   │   ├─ [2553] FiatTokenV2_2::balanceOf(UniswapV3Pool: [0xC6962004f452bE9203591991D15f6b388e09E8D0]) [delegatecall]
    │   │   │   └─ ← [Return] 58611786715385 [5.861e13]
    │   │   └─ ← [Return] 58611786715385 [5.861e13]
    │   ├─ [31990] SwapRouter::uniswapV3SwapCallback(-323327000000000000 [-3.233e17], 1500271940 [1.5e9], 0x000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000400000000000000000000000008c19e9ad4d2c3db1a0966b1b91de325274e233cf000000000000000000000000000000000000000000000000000000000000002b82af49447d8a07e3bd95bd0d56f35241523fbab10001f4af88d065e77c8cc2239327c5edb3a432268e5831000000000000000000000000000000000000000000)
    │   │   ├─ [22828] FiatTokenProxy::fallback(0x8c19E9AD4D2c3db1a0966b1b91DE325274E233cf, UniswapV3Pool: [0xC6962004f452bE9203591991D15f6b388e09E8D0], 1500271940 [1.5e9])
    │   │   │   ├─ [22154] FiatTokenV2_2::transferFrom(0x8c19E9AD4D2c3db1a0966b1b91DE325274E233cf, UniswapV3Pool: [0xC6962004f452bE9203591991D15f6b388e09E8D0], 1500271940 [1.5e9]) [delegatecall]
    │   │   │   │   ├─ emit Transfer(from: 0x8c19E9AD4D2c3db1a0966b1b91DE325274E233cf, to: UniswapV3Pool: [0xC6962004f452bE9203591991D15f6b388e09E8D0], value: 1500271940 [1.5e9])
    │   │   │   │   └─ ← [Return] true
    │   │   │   └─ ← [Return] true
    │   │   └─ ← [Stop]
    │   ├─ [1250] FiatTokenProxy::fallback(UniswapV3Pool: [0xC6962004f452bE9203591991D15f6b388e09E8D0]) [staticcall]
    │   │   ├─ [553] FiatTokenV2_2::balanceOf(UniswapV3Pool: [0xC6962004f452bE9203591991D15f6b388e09E8D0]) [delegatecall]
    │   │   │   └─ ← [Return] 58613286987325 [5.861e13]
    │   │   └─ ← [Return] 58613286987325 [5.861e13]
    │   ├─ emit Swap(sender: SwapRouter: [0xE592427A0AEce92De3Edee1F18E0157C05861564], recipient: 0x8c19E9AD4D2c3db1a0966b1b91DE325274E233cf, amount0: -323327000000000000 [-3.233e17], amount1: 1500271940 [1.5e9], sqrtPriceX96: 5395545769060596277542135 [5.395e24], liquidity: 12227666759275331478 [1.222e19], tick: -191900 [-1.919e5])
    │   └─ ← [Return] -323327000000000000 [-3.233e17], 1500271940 [1.5e9]
    └─ ← [Return] 1500271940 [1.5e9]
]]

  it("computes correct depth for every exact line in sample", function()
    local lines = {}
    for l in sample:gmatch("[^\n]+") do
      table.insert(lines, l)
    end

    -- Expected depths per line (1-indexed), matching 'lines' exactly
    local expected = {
      0, --  1: [[
      0, --  2:   [108428] SwapRouter::exactOutputSingle(...)
      1, --  3:     ├─ [100745] UniswapV3Pool::swap(...)
      2, --  4:     │   ├─ [20300] TransparentUpgradeableProxy::fallback(...)
      3, --  5:     │   │   ├─ [13054] aeWETH::transfer(...)
      4, --  6:     │   │   │   ├─ emit Transfer(...)
      4, --  7:     │   │   │   └─ ← [Return] true
      3, --  8:     │   │   └─ ← [Return] true
      2, --  9:     │   ├─ [9750] FiatTokenProxy::fallback(...)
      3, -- 10:     │   │   ├─ [2553] FiatTokenV2_2::balanceOf(...)
      4, -- 11:     │   │   │   └─ ← [Return] 58611786715385
      3, -- 12:     │   │   └─ ← [Return] 58611786715385
      2, -- 13:     │   ├─ [31990] SwapRouter::uniswapV3SwapCallback(...)
      3, -- 14:     │   │   ├─ [22828] FiatTokenProxy::fallback(...)
      4, -- 15:     │   │   │   ├─ [22154] FiatTokenV2_2::transferFrom(...)
      5, -- 16:     │   │   │   │   ├─ emit Transfer(...)
      5, -- 17:     │   │   │   │   └─ ← [Return] true
      4, -- 18:     │   │   │   └─ ← [Return] true
      3, -- 19:     │   │   └─ ← [Stop]
      2, -- 20:     │   ├─ [1250] FiatTokenProxy::fallback(...)
      3, -- 21:     │   │   ├─ [553] FiatTokenV2_2::balanceOf(...)
      4, -- 22:     │   │   │   └─ ← [Return] 58613286987325
      3, -- 23:     │   │   └─ ← [Return] 58613286987325
      2, -- 24:     │   ├─ emit Swap(...)
      2, -- 25:     │   └─ ← [Return] -323327000000000000 ...
      1, -- 26:     └─ ← [Return] 1500271940 ...
    }

    assert.are.equal(#expected, #lines, "sample/expected line count mismatch")

    for i, line in ipairs(lines) do
      local got = trace.depth_for_line(line)
      assert.are.equal(
        expected[i],
        got,
        string.format("line %d depth mismatch. line=\n%s\n", i, line)
      )
    end
  end)
end)
