local vim = vim
local function get_clipboard()
  if vim.env.SPIN == "1" then
    return {
      name = "pbcopy",
      copy = {
        ["+"] = "pbcopy",
        ["*"] = "pbcopy",
      },
      paste = {
        ["+"] = "pbpaste",
        ["*"] = "pbpaste",
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
    { "mbbill/undotree", keys = { { "<leader>u", vim.cmd.UndotreeToggle } } },
    -- Git integration
    { "tpope/vim-fugitive", cmd = { "G", "Git" } },
    -- Adds `end` in Ruby, Lua, etc.
    { "RRethy/nvim-treesitter-endwise", lazy = false },
    -- Better % matching
    { "andymass/vim-matchup", lazy = false },
    -- Manage surrounding characters
    { "tpope/vim-surround", lazy = false },
    -- Repeat stuff
    { "tpope/vim-repeat", lazy = false },
    -- Better targest, incl. q for quoted strings
    { "wellle/targets.vim", lazy = false },
    -- Better search, jumping, etc.
    {
      "folke/flash.nvim",
      event = "VeryLazy",
      opts = {
        modes = {
          search = { enabled = false },
        },
      },
      keys = {
        {
          "s",
          mode = { "n", "x", "o" },
          function() require("flash").jump() end,
          desc = "Flash",
        },
        {
          "S",
          mode = { "n", "o", "x" },
          function() require("flash").treesitter() end,
          desc = "Flash Treesitter",
        },
        {
          "r",
          mode = "o",
          function() require("flash").remote() end,
          desc = "Remote Flash",
        },
        {
          "R",
          mode = { "o", "x" },
          function() require("flash").treesitter_search() end,
          desc = "Flash Treesitter Search",
        },
        {
          "<c-s>",
          mode = { "c" },
          function() require("flash").toggle() end,
          desc = "Toggle Flash Search",
        },
      },
    },
    -- Use virtual lines to display diagnostic text
    {
      "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
      lazy = false,
      init = function() require("lsp_lines").setup() end,
    },
    -- Show all your problems
    {
      "folke/trouble.nvim",
      keys = {
        {
          "<leader>Tx",
          function() require("trouble").toggle() end,
          desc = "Show trouble",
        },
      },
    },
    -- Theme
    { "dracula/vim" },
    -- Align text based on content
    { "junegunn/vim-easy-align", keys = { { "ga", "<Plug>(EasyAlign)", mode = "x" } } },
    -- Indentation text objects
    { "michaeljsmith/vim-indent-object", lazy = false },
    -- Language aware text objects
    { "nvim-treesitter/nvim-treesitter-textobjects", lazy = false },
    -- Copilot
    {
      "zbirenbaum/copilot.lua",
      lazy = false,
      init = function()
        require("copilot").setup {
          suggestion = {
            auto_trigger = true,
            keymap = {
              accept = "<C-l>",
            },
          },
        }
      end,
    },
    -- Automatically add closing brackets, etc.
    { "windwp/nvim-autopairs", lazy = false },
    -- Mason configuration
    {
      "williamboman/mason-lspconfig.nvim",
      lazy = false,
      opts = {
        ensure_installed = {
          -- "lua_ls",
          "jsonls",
          "yamlls",
          "ruby_ls",
          "sorbet",
        },
      },
    },
    {
      "jay-babu/mason-null-ls.nvim",
      opts = {
        ensure_installed = {
          "jq",
          "stylua",
        },
      },
    },
    {
      "nvim-treesitter/nvim-treesitter",
      opts = {
        ensure_installed = { "lua", "ruby", "javascript" },
        endwise = { enable = true },
        matchup = { enable = true },
      },
    },
    { "otavioschwanck/telescope-alternate" },
    {
      "nvim-telescope/telescope.nvim",
      keys = {
        { "<C-a>", "<cmd>Telescope telescope-alternate alternate_file<cr>" },
      },
      opts = {
        pickers = {
          find_files = {
            hidden = true,
          },
        },
        extensions = {
          ["telescope-alternate"] = {
            presets = { "rails", "rspec" },
            mappings = {
              {
                "components/(.*)/app/.*/(.*).rb",
                {
                  { "components/[1]/test/**/[2]_test.rb", "Test" },
                },
              },
              {
                "components/(.*)/test/.*/(.*)_test.rb",
                {
                  { "components/[1]/app/controllers/**/[2].rb", "Controller" },
                  { "components/[1]/app/models/**/[2].rb", "Model" },
                },
              },
              { "app/.*/(.*).rb", {
                { "test/**/[1]_test.rb", "Test" },
              } },
              {
                "test/.*/(.*)_test.rb",
                {
                  { "app/**/[1].rb", "Implementation" },
                },
              },
              {
                "gems/(.*)/lib/.*/(.*).rb",
                {
                  { "gems/[1]/test/**/[2]_test.rb", "Test" },
                },
              },
              {
                "gems/(.*)/test/.*/(.*)_test.rb",
                {
                  { "gems/[1]/**/[2].rb", "Implementation" },
                },
              },
            },
          },
        },
      },
    },
    -- Configure cmp sources
    -- In particular, configure the buffer source to use all buffers
    {
      "hrsh7th/nvim-cmp",
      opts = function(_, opts)
        local cmp = require "cmp"
        local cmp_buffer = require "cmp_buffer"
        opts.sorting = {
          comparators = {
            -- Use cmp_buffer:compare_locality
            function(...) return cmp_buffer:compare_locality(...) end,
          },
        }
        opts.sources = cmp.config.sources {
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip", priority = 750 },
          {
            name = "buffer",
            priority = 500,
            option = {
              get_bufnrs = function() return vim.api.nvim_list_bufs() end,
            },
          },
          { name = "path", priority = 250 },
        }
        return opts
      end,
    },
    -- Handle git conflicts
    {
      "akinsho/git-conflict.nvim",
      version = "*",
      lazy = false,
      opts = { highlights = { incoming = "DiffAdd", current = "DiffAdd", ancestor = "DiffAdd" } },
    },
    {
      "nvim-neo-tree/neo-tree.nvim",
      opts = function(_, opts)
        opts.window.width = "auto"
        return opts
      end,
    },
    {
      "ThePrimeagen/harpoon",
      keys = {
        {
          "<leader>hm",
          function() require("harpoon.ui").toggle_quick_menu() end,
          desc = "Harpoon Menu",
        },
        {
          "<leader>ha",
          function() require("harpoon.mark").add_file() end,
          desc = "Add file",
        },
        {
          "<leader>hr",
          function() require("harpoon.mark").rm_file() end,
          desc = "Remove file",
        },
        {
          "<leader>hn",
          function() require("harpoon.ui").nav_next() end,
          desc = "Next file",
        },
        {
          "<leader>hp",
          function() require("harpoon.ui").nav_prev() end,
          desc = "Previous file",
        },
        {
          "<leader>h1",
          function() require("harpoon.ui").nav_file(1) end,
          desc = "Navigate to file 1",
        },
        {
          "<leader>h2",
          function() require("harpoon.ui").nav_file(2) end,
          desc = "Navigate to file 2",
        },
        {
          "<leader>h3",
          function() require("harpoon.ui").nav_file(3) end,
          desc = "Navigate to file 3",
        },
        {
          "<leader>h4",
          function() require("harpoon.ui").nav_file(4) end,
          desc = "Navigate to file 4",
        },
      },
    },
    {
      "catlee/pull_diags.nvim",
      -- dev = true,
      event = "LspAttach",
      opts = {},
    },
    (vim.env.SPIN == "1" and { "Shopify/spin-hud" }) or nil,
  },
  colorscheme = "dracula",
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
  mappings = {
    n = {
      ["<leader>h"] = { desc = "Harpoon" },
      ["<leader>E"] = { "<cmd>e ~/.config/nvim/lua/user/init.lua<cr>", desc = "Edit init.lua" },
      ["n"] = { "nzz" },
      ["N"] = { "Nzz" },
    },
    t = {
      ["<C-O>"] = { "<C-\\><C-n>" },
    },
  },
  diagnostics = {
    -- This is handled by the lsp_lines plugin
    virtual_text = false,
  },
  lsp = {
    formatting = {
      timeout_ms = 10000,
    },
    config = {
      sorbet = function(opts)
        -- Only enable sorbet if the repo has it enabled
        opts.root_dir = require("lspconfig.util").root_pattern "sorbet/config"
        return opts
      end,
      ruby_ls = function(opts)
        opts.root_dir = require("lspconfig.util").find_git_ancestor
        return opts
      end,
    },
  },
}
