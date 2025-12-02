-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Prevent dedenting in Ruby after typing '.'
vim.cmd "autocmd FileType ruby setlocal indentkeys-=."

local grokt_search = function()
  local selection = ""

  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "CTRL-V" then
    vim.cmd 'normal! ""y'
    selection = vim.fn.getreg('"'):gsub("%s+", " ") or ""
  end

  vim.ui.input({
    prompt = "Grokt search: ",
    default = selection,
  }, function(input)
    if input and input ~= "" then
      local encoded = vim.uri_encode(input)
      local url = "https://grokt.shopify.io/results?q=" .. encoded
      vim.fn.system('open "' .. url .. '"')
    end
  end)
end

vim.keymap.set({ "n", "v" }, "<leader>gk", grokt_search, { desc = "Search Grokt" })
