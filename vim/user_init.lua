local function get_clipboard()
  if vim.env.SPIN == "1" then
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
    return nil
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
    {
      "hrsh7th/nvim-cmp",
      dependencies = { "zbirenbaum/copilot-cmp" },
      opts = function(_, opts)
        local cmp = require "cmp"
        opts.sources = cmp.config.sources {
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip",  priority = 750 },
          { name = "buffer",   priority = 500 },
          { name = "path",     priority = 250 },
          { name = "copilot",  priority = 700 },
        }
        return opts
      end,
    },
    {
      "zbirenbaum/copilot.lua",
      lazy = false,
      opts = { suggestion = { enabled = false }, panel = { enabled = false } }
    },
    {
      "zbirenbaum/copilot-cmp",
      lazy = false,
      after = { "copilot.lua" },
      config = function()
        require("copilot_cmp").setup()
      end
    },
    -- Automatically add closing brackets, etc.
    { "windwp/nvim-autopairs", lazy = false },
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
    {
      "nvim-telescope/telescope.nvim",
      opts = {
        pickers = {
          find_files = {
            hidden = true
          }
        }
      }
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
    g = {
      clipboard = get_clipboard(),
    },
    opt = {
      clipboard = "",
      cmdheight = 1,
    },
  },
}
