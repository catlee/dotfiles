local function get_clipboard()
  if vim.env.spin == "1" then
    return {
      name = 'pbcopy',
      copy = {
        ['+'] = 'pbcopy',
        ['*'] = 'pbcopy'
      },
      paste = {
        ['+'] = 'pbpaste',
        ['*'] = 'pbpaste'
      },
      cache_enabled = 1,
    }
  else
    return ""
  end
end

return {
  updater = {
    channel = "stable",
  },
  plugins = {
    { "RRethy/nvim-treesitter-endwise" },
    { "andymass/vim-matchup" },
    { "tpope/vim-surround",             lazy = false },
    { "tpope/vim-repeat",               lazy = false },
    { "wellle/targets.vim" },
    { "machakann/vim-textobj-delimited" },
    {
      "ggandor/leap.nvim",
      init = function()
        require("leap").add_default_mappings()
      end,
    },
    {
      "ggandor/flit.nvim",
      init = function()
        require("flit").setup()
      end
    },
    { "folke/tokyonight.nvim" },
    { "junegunn/vim-easy-align" },
    { "michaeljsmith/vim-indent-object" },
    { "nvim-treesitter/nvim-treesitter-textobjects" },
    { "https://github.com/github/copilot.vim" },
    { "windwp/nvim-autopairs" },
    { "windwp/nvim-ts-autotag" },
    {
      "williamboman/mason-lspconfig.nvim",
      opts = {
        ensure_installed = {
          "lua_ls",
          "jsonls",
          "yamlls"
        }
      }
    },
    {
      "nvim-treesitter/nvim-treesitter",
      opts = {
        ensure_installed = { "lua" },
      },
    },
    (vim.env.SPIN == '1' and { "Shopify/spin-hud" }) or nil,
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
    config = {
      ["ruby_ls"] = {
        -- TODO: Only run this if we have a Gemfile with ruby-lsp in it
        cmd = { "bundle", "exec", "ruby-lsp" }
      },
    }
  },
  options = {
    opt = {
      clipboard = get_clipboard(),
      cmdheight = 1,
    }
  },
}
