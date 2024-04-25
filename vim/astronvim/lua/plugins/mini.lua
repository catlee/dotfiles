---@type LazySpec
return {
  {
    "echasnovski/mini.nvim",
    version = false,
    config = function(_, _)
      require("mini.ai").setup()
      require("mini.surround").setup()
    end,
  },
}
