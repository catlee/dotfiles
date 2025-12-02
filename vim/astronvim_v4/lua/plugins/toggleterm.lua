return {
  "akinsho/toggleterm.nvim",
  opts = {
    float_opts = {
      border = "curved",
      width = math.floor(vim.o.columns * 0.75),
      height = math.floor(vim.o.lines * 0.75),
      winblend = 0,
      highlights = {
        border = "Normal",
        background = "Normal",
      },
    },
  },
}
