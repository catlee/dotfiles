---@type LazySpec
return {
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp = require "cmp"
      local cmp_buffer = require "cmp_buffer"
      local lspkind = require "lspkind"
      opts.formatting = {
        format = lspkind.cmp_format {
          mode = "symbol",
          max_width = 50,
          symbol_map = { Copilot = "" },
        },
      }
      opts.sorting = {
        comparators = {
          -- Use cmp_buffer:compare_locality
          function(...) return cmp_buffer:compare_locality(...) end,
        },
      }
      opts.sources = cmp.config.sources {
        { name = "copilot", priority = 1200 },
        { name = "nvim_lsp", priority = 1000 },
        { name = "luasnip", priority = 750 },
        {
          name = "buffer",
          priority = 500,
          option = {
            get_bufnrs = function() return vim.api.nvim_list_bufs() end,
          },
        },
        { name = "path", priority = 250 },
      }
      return opts
    end,
  },
}
