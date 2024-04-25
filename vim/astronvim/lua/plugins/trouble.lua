-- Show all your problems
---@type LazySpec
return {
  {
    "folke/trouble.nvim",
    keys = {
      {
        "<leader>Tx",
        function() require("trouble").toggle() end,
        desc = "Show trouble",
      },
    },
  },
}
