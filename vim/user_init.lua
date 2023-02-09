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
      { "https://github.com/github/copilot.vim" },
      (vim.env.SPIN == '1' and { "Shopify/spin-hud" }) or nil,
    },
    treesitter = {
      ensure_installed = {
        "rust", "python", "vim", "yaml", "make", "ruby",
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
      },
      incremental_selection = {
        keymaps = {
          init_selection = "<c-space>",
          node_incremental = "<c-space>",
          scope_incremental = "<c-s>",
          node_decremental = '<c-backspace>',

        }
      }
    },
    ["mason-lspconfig"] = {
      ensure_installed = { "rust_analyzer", "ruby_ls" },
    },
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

  lsp = {
    formatting = {
      timeout_ms = 10000,
    },
    ["server-settings"] = {
      ["ruby_ls"] = {
        -- TODO: Only run this if we have a Gemfile with ruby-lsp in it
        cmd = { "bundle", "exec", "ruby-lsp" }
      },
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
