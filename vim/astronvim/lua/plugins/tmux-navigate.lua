---@type LazySpec
return {
  {
    "sunaku/tmux-navigate",
    lazy = false,
    enabled = vim.env.TMUX ~= nil,
    config = function()
      -- Create augroup for tmux terminal handling
      local augroup = vim.api.nvim_create_augroup("TmuxTerminalIntegration", { clear = true })
      
      -- Enter insert mode when entering a terminal window
      vim.api.nvim_create_autocmd("WinEnter", {
        group = augroup,
        pattern = "*",
        callback = function()
          if vim.bo.buftype == "terminal" then
            vim.cmd("startinsert")
          end
        end,
      })
    end,
  },
}
