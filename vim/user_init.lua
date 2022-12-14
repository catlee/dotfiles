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
      { "justinmk/vim-sneak" },
      { "folke/tokyonight.nvim" },
      { "junegunn/vim-easy-align" },
      { "michaeljsmith/vim-indent-object" },
      { "nvim-treesitter/nvim-treesitter-textobjects" },
      (vim.env.SPIN == '1' and { "Shopify/spin-hud" }) or nil,
    },
    treesitter = {
      ensure_installed = {
        "rust", "python", "ruby", "vim", "yaml", "make",
        "diff", "regex", "json", "json5", "lua"
      },
      endwise = { enable = true },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
          }
        }
      }
    },
    ["mason-lspconfig"] = {
      ensure_installed = { "rust_analyzer" },
    }
  },

  colorscheme = "tokyonight-night",

  mappings = {
    n = {
      ["<leader>E"]  = { "<cmd>e ~/.config/nvim/lua/user/init.lua<cr>", desc = "Edit init.lua" },
      ["<leader>TA"] = { "<cmd>TestSuite<cr>", desc = "Test Suite" },
      ["<leader>TT"] = { "<cmd>TestLast<cr>", desc = "Test Last" },
      ["<leader>Tt"] = { "<cmd>TestNearest<cr>", desc = "Test Nearest" },
      ["<leader>TF"] = { "<cmd>TestFile<cr>", desc = "Test File" },
      ["n"]          = { "nzz" },
      ["N"]          = { "Nzz" },
    },
    -- Visual mode
    x = {
      ["ga"] = { "<Plug>(EasyAlign)" },
    },
    t = {
      -- Ctrl-O in terminal to enter normal mode
      ["<C-O>"] = { "<C-\\><C-n>" },
    }
  },

  polish = function()
    vim.g['test#strategy'] = 'neovim'
    vim.g['sneak#label'] = 1
    vim.api.nvim_set_option('cmdheight', 1) -- avoid annoying prompts to hit enter
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
