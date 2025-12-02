---@type LazySpec
return {
  {
    "Shopify/shadowenv",
    lazy = false,
    cond = function()
      return vim.fn.executable("shadowenv") == 1
    end,
  },
}
