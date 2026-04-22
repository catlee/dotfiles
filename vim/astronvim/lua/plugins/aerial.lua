---@type LazySpec
return {
  {
    "stevearc/aerial.nvim",
    opts = {
      -- Work around Treesitter node API mismatches that can crash Aerial
      -- on some Neovim/plugin version combinations.
      backends = { "lsp", "markdown", "man" },
    },
  },
}
