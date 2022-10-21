return {
  updater = {
    channel = "stable",
  },
  plugins = {
    init = {
      { "RRethy/nvim-treesitter-endwise" },
      { "andymass/vim-matchup" },
      { "tpope/vim-surround" },
      { "tpope/vim-repeat" },
      { "wellle/targets.vim" },
      { "machakann/vim-textobj-delimited" },
      { "vim-test/vim-test" },
    },
    treesitter = {
      endwise = { enable = true },
    },
  },

  mappings = {
    n = {
      ["<leader>TA"] = { "<cmd>TestSuite<cr>", desc = "Test Suite" },
      ["<leader>TT"] = { "<cmd>TestLast<cr>", desc = "Test Last" },
    }
  },

  polish = function()
    if vim.env.SPIN == '1' then
      -- Enable copy/paste on spin
      vim.cmd([[
      let g:clipboard = {
        \ 'name': 'pbcopy',
        \ 'copy': {'+': 'pbcopy', '*': 'pbcopy'},
        \ 'paste': {'+': 'pbpaste', '*': 'pbpaste'},
        \ 'cache_enabled': 1 }
        ]])
      end
    end,
  }
