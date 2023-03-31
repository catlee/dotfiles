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
    -- Undo tree
    { "mbbill/undotree",                keys = { { "<leader>u", vim.cmd.UndotreeToggle } } },
    -- Git integration
    { "tpope/vim-fugitive",             cmd = { "G", "Git" } },
    -- Adds `end` in Ruby, Lua, etc.
    { "RRethy/nvim-treesitter-endwise", lazy = false },
    -- Better % matching
    { "andymass/vim-matchup",           lazy = false },
    -- Manage surrounding characters
    { "tpope/vim-surround",             lazy = false },
    -- Repeat stuff
    { "tpope/vim-repeat",               lazy = false },
    -- Better targest, incl. q for quoted strings
    { "wellle/targets.vim",             lazy = false },
    -- Jump to text with s/S
    {
      "ggandor/leap.nvim",
      lazy = false,
      init = function()
        require("leap").add_default_mappings()
      end,
    },
    -- Better f/t
    {
      "ggandor/flit.nvim",
      lazy = false,
      init = function()
        require("flit").setup()
      end
    },
    { "folke/tokyonight.nvim" },
    -- Align text based on content
    { "junegunn/vim-easy-align",                     keys = { { "ga", "<Plug>(EasyAlign)", mode = "x" } } },
    -- Indentation text objects
    { "michaeljsmith/vim-indent-object",             lazy = false },
    -- Language aware text objects
    { "nvim-treesitter/nvim-treesitter-textobjects", lazy = false },
    -- Copilot
    { "https://github.com/github/copilot.vim",       lazy = false },
    -- Automatically add closing brackets, etc.
    { "windwp/nvim-autopairs",                       lazy = false },
    -- Mason configuration
    {
      "williamboman/mason-lspconfig.nvim",
      lazy = false,
      opts = {
        ensure_installed = {
          "lua_ls",
          "jsonls",
          "yamlls",
          "ruby_ls",
        }
      }
    },
    {
      "nvim-treesitter/nvim-treesitter",
      opts = {
        ensure_installed = { "lua", "ruby" },
      },
    },
    (vim.env.SPIN == '1' and { "Shopify/spin-hud" }) or nil,
  },
  colorscheme = "tokyonight-night",
  mappings = {
    n = {
      ["<leader>E"] = { "<cmd>e ~/.config/nvim/lua/user/init.lua<cr>", desc = "Edit init.lua" },
      ["n"]         = { "nzz" },
      ["N"]         = { "Nzz" },
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
  },
  options = {
    opt = {
      clipboard = get_clipboard(),
      cmdheight = 1,
    }
  },
}
