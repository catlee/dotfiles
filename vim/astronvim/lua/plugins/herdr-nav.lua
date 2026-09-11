---@type LazySpec
return {
  {
    name = "vim-herdr-navigation",
    dir = vim.fn.expand("~/.config/herdr/plugins/github/vim-herdr-navigation-a8bf42123d81"),
    lazy = false,
    enabled = vim.env.HERDR_PANE_ID ~= nil and vim.env.HERDR_PANE_ID ~= "",
    config = function()
      dofile(vim.fn.expand("~/.config/herdr/plugins/github/vim-herdr-navigation-a8bf42123d81/editor/nvim.lua"))
    end,
  },
}
