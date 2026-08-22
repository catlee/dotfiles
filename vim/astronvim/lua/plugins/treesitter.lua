-- Treesitter's old `master` branch is incompatible with Neovim 0.12.
---@type LazySpec
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    commit = "71bf1665f804d46f7e4b24ad7ffc11f6ea5b271a",
    main = "nvim-treesitter",
    dependencies = {},
    opts = {
      install_dir = vim.fn.stdpath "data" .. "/site",
    },
    config = function(_, opts)
      require("nvim-treesitter").setup(opts)

      -- Highlighting is now provided by Neovim itself.
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
          if lang and pcall(vim.treesitter.start, args.buf, lang) then
            vim.wo.foldmethod = "expr"
            vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
          end
        end,
      })
    end,
  },
  -- These extensions target the removed nvim-treesitter `master` API.
  { "nvim-treesitter/nvim-treesitter-textobjects", enabled = false },
  { "RRethy/nvim-treesitter-endwise", enabled = false },
}
