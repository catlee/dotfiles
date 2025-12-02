---@type LazySpec
return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function() require("harpoon"):setup() end,
    keys = {
      {
        "<leader>ha",
        function() require("harpoon"):list():add() end,
        desc = "Harpoon Add",
      },
      {
        "<leader>he",
        function()
          local harpoon = require "harpoon"
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end,
        desc = "Harpoon Edit",
      },
      {
        "<tab>",
        function() require("harpoon"):list():next { ui_nav_wrap = true } end,
        desc = "Harpoon next",
      },
      {
        "<leader>hp",
        function() require("harpoon"):list():prev() end,
        desc = "Harpoon previous",
      },
    },
  },
  {
    "AstroNvim/astrocore",
    opts = {
      mappings = {
        n = {
          ["<Leader>h"] = { desc = "Harpoon" },
        },
      },
    },
  },
}
