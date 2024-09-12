---@type LazySpec
return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  lazy = false,
  version = false,
  config = function()
    local openai = require "avante.providers.openai"
    local has_openai_key = vim.fn.executable "openai_key" == 1

    require("avante").setup {
      -- @type AvanteProvider
      provider = has_openai_key and "shopify-ai" or nil,
      vendors = {
        ["shopify-ai"] = has_openai_key and {
          endpoint = "https://proxy.shopify.ai/v3/v1",
          model = "anthropic:claude-3-5-sonnet",
          api_key_name = "cmd:openai_key cat",
          parse_curl_args = openai.parse_curl_args,
          parse_response_data = openai.parse_response,
        } or nil,
      },
      highlights = {
        diff = {
          incoming = "DiffChange",
        },
      },
    }
  end,
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = "make",
  -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  dependencies = {
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below dependencies are optional,
    "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    "zbirenbaum/copilot.lua", -- for providers='copilot'
    {
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
}
