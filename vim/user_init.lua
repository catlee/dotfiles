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
    -- Use virtual lines to display diagnostic text
    {
      "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
      lazy = false,
      init = function()
        require("lsp_lines").setup()
      end,
    },
    -- Show all your problems
    {
      "folke/trouble.nvim",
      keys = {
        { "<leader>Tx", function() require("trouble").toggle() end, desc = "Show trouble" },
      }
    },
    -- Theme
    { "dracula/vim" },
    -- Align text based on content
    { "junegunn/vim-easy-align",                     keys = { { "ga", "<Plug>(EasyAlign)", mode = "x" } } },
    -- Indentation text objects
    { "michaeljsmith/vim-indent-object",             lazy = false },
    -- Language aware text objects
    { "nvim-treesitter/nvim-treesitter-textobjects", lazy = false },
    -- Copilot
    {
      "zbirenbaum/copilot.lua",
      lazy = false,
      init = function()
        require("copilot").setup({
          suggestion = {
            auto_trigger = true,
            keymap = {
              accept = "<C-l>",
            }
          }
        })
      end
    },
    -- Automatically add closing brackets, etc.
    { "windwp/nvim-autopairs",             lazy = false },
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
      keys = {
        { '<C-a>', "<cmd>Telescope telescope-alternate alternate_file<cr>" }
      },
      opts = {
        pickers = {
          find_files = {
            hidden = true
          }
        },
        extensions = {
          ["telescope-alternate"] = {
            presets = { "rails", "rspec" },
            mappings = {
              { 'components/(.*)/app/.*/(.*).rb', {
                { 'components/[1]/test/**/[2]_test.rb', 'Test' }
              } },
              { 'components/(.*)/test/.*/(.*)_test.rb', {
                { 'components/[1]/app/controllers/**/[2].rb', 'Controller' },
                { 'components/[1]/app/models/**/[2].rb',      'Model' },
              } },
              { 'app/.*/(.*).rb', {
                { 'test/**/[1]_test.rb', 'Test' }
              } },
              { 'test/.*/(.*)_test.rb', {
                { 'app/**/[1].rb', 'Implementation' }
              } }
            }
          }
        }
      }
    },
    {
      "vim-test/vim-test",
      keys = {
        { "<leader>TT", vim.cmd.TestNearest, desc = "Test nearest" },
        { "<leader>Tf", vim.cmd.TestFile,    desc = "Test file" },
        { "<leader>Ts", vim.cmd.TestSuite,   desc = "Test suite" },
        { "<leader>Tl", vim.cmd.TestLast,    desc = "Test last" },
        { "<leader>Tv", vim.cmd.TestVisit,   desc = "Test visit" },
      }
    },
    -- Configure cmp sources
    -- In particular, configure the buffer source to use all buffers
    {
      "hrsh7th/nvim-cmp",
      opts = function(_, opts)
        local cmp = require("cmp")
        local cmp_buffer = require("cmp_buffer")
        opts.sorting = {
          comparators = {
            -- Use cmp_buffer:compare_locality
            function(...)
              return cmp_buffer:compare_locality(...)
            end,
          }
        }
        opts.sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip",  priority = 750 },
          {
            name = "buffer",
            priority = 500,
            option = {
              get_bufnrs = function()
                return vim.api.nvim_list_bufs()
              end,
            },
          },
          { name = "path", priority = 250 },
        })
        return opts
      end,
    },
    { "otavioschwanck/telescope-alternate" },
    (vim.env.SPIN == '1' and { "Shopify/spin-hud" }) or nil,
  },
  colorscheme = "dracula",
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
  options = {
    g = {
      clipboard = get_clipboard(),
      copilot_no_tab_map = true,
    },
    opt = {
      clipboard = "",
      cmdheight = 1,
    },
  },
  diagnostics = {
    -- This is handled by the lsp_lines plugin
    virtual_text = false,
  },
  lsp = {
    formatting = {
      timeout_ms = 10000
    },
    config = {
      ruby_ls = function()
        local util = require "lspconfig.util";
        return {
          cmd = { 'bundle', 'exec', 'ruby-lsp' },
          root_dir = util.find_git_ancestor,
          init_options = {
            formatting = "auto"
          }
        }
      end
    },
  },
}
