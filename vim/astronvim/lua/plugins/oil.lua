---@type LazySpec
return {
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = { { "-", "<cmd>Oil<cr>", desc = "Open parent directory" } },
    opts = {
      keymaps = {
        ["gr"] = "actions.refresh",
      },
    },
  },
}
