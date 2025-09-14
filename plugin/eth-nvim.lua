-- User commands for eth-nvim

vim.api.nvim_create_user_command("EthTraceFoldEnable", function()
  require("eth-nvim.trace").enable(0)
end, { desc = "Enable folding for foundry trace output in current buffer" })

vim.api.nvim_create_user_command("EthTraceFoldDisable", function()
  require("eth-nvim.trace").disable(0)
end, { desc = "Disable trace folding in current buffer" })

vim.api.nvim_create_user_command("EthTraceFoldToggle", function()
  local fm = vim.api.nvim_buf_get_option(0, "foldmethod")
  if fm == "expr" then
    require("eth-nvim.trace").disable(0)
  else
    require("eth-nvim.trace").enable(0)
  end
end, { desc = "Toggle trace folding in current buffer" })
