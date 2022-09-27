return {
  plugins = {
    init = {
      { "RRethy/nvim-treesitter-endwise" },
      { "andymass/vim-matchup" },
      { "tpope/vim-surround" },
      { "tpope/vim-repeat" },
      { "wellle/targets.vim" },
      { "machakann/vim-textobj-delimited" },
    },
    treesitter = {
      endwise = { enable = true },
    },
  }
}
