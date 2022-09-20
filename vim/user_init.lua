return {
  plugins = {
    init = {
      { "RRethy/nvim-treesitter-endwise" },
      { "andymass/vim-matchup" },
      { "tpope/vim-surround" },
      { "tpope/vim-repeat" },
    },
    treesitter = {
      endwise = { enable = true },
    },
  }
}
