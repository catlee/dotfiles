---@type LazySpec
return {
  {
    "echasnovski/mini.nvim",
    version = false,
    config = function(_, _)
      require("mini.ai").setup()
      require("mini.surround").setup()
      require("mini.animate").setup()
    end,
  },
  {
    "nvim-mini/mini.icons",
    opts = {},
    lazy = true,
    specs = {
      { "nvim-tree/nvim-web-devicons", enabled = false, optional = true },
    },
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },
}
