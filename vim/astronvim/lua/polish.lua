-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Prevent dedenting in Ruby after typing '.'
vim.cmd "autocmd FileType ruby setlocal indentkeys-=."

-- Don't start firenvim by default
if vim.g.started_by_firenvim then
  vim.g.firenvim_config = {
    localSettings = {
      [".*"] = { takeover = "never" },
    },
  }
end

-- Make <leader>/ repeatable
vim.keymap.set("n", "<leader>/", require("Comment.api").call("toggle.linewise.current", "g@$"), { expr = true })
