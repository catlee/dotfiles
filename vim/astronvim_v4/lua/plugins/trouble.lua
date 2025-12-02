-- Show all your problems
---@type LazySpec
return {
  {
    "folke/trouble.nvim",
    keys = {
      {
        "<leader>T",
        function() require("trouble").toggle() end,
        desc = "Show trouble",
      },
    },
  },
}
