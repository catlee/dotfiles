-- Customizations for treesitter
---@type LazySpec
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if not opts.ensure_installed then opts.ensure_installed = {} end
      vim.list_extend(opts.ensure_installed, {
        "lua",
        "ruby",
        "python",
        "rust",
        "javascript",
        "markdown",
        "markdown_inline",
        "typescript",
      })
      opts.endwise = { enable = true }
      opts.matchup = { enable = true }

      -- Disable treesitter keybindings
      opts.incremental_selection = { enable = false }
      opts.textobjects = { enable = false }
    end,
  },
}
