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
      opts.snippet = {
        expand = function(args) require("luasnip").lsp_expand(args.body) end,
      }
      opts.sources = cmp.config.sources {
        { name = "copilot" },
        { name = "nvim_lsp" },
        { name = "luasnip" },
        {
          name = "buffer",
          option = {
            get_bufnrs = function() return vim.api.nvim_list_bufs() end,
          },
        },
        { name = "path" },
      }
      return opts
    end,
  },
}
