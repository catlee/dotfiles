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

-- textDocument/diagnostic support until 0.10.0 is released
_timers = {}
local function setup_diagnostics(client, buffer)
  if require("vim.lsp.diagnostic")._enable then return end

  local diagnostic_handler = function()
    local params = vim.lsp.util.make_text_document_params(buffer)
    client.request("textDocument/diagnostic", { textDocument = params }, function(err, result)
      if err then
        local err_msg = string.format("diagnostics error - %s", vim.inspect(err))
        vim.lsp.log.error(err_msg)
      end
      if not result then return end
      vim.lsp.diagnostic.on_publish_diagnostics(
        nil,
        vim.tbl_extend("keep", params, { diagnostics = result.items }),
        { client_id = client.id }
      )
    end)
  end

  diagnostic_handler() -- to request diagnostics on buffer when first attaching

  vim.api.nvim_buf_attach(buffer, false, {
    on_lines = function()
      if _timers[buffer] then vim.fn.timer_stop(_timers[buffer]) end
      _timers[buffer] = vim.fn.timer_start(200, diagnostic_handler)
    end,
    on_detach = function()
      if _timers[buffer] then vim.fn.timer_stop(_timers[buffer]) end
    end,
  })
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
          -- "stylua"
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
    -- Debugging
    { "suketa/nvim-dap-ruby", keys = { { "<leader>d" }, { "<F5>" } }, config = true, opts = {} },
    {
      "theHamsta/nvim-dap-virtual-text",
      keys = { { "<leader>d" }, { "<F5>" } },
      config = true,
      opts = {},
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
    (vim.env.SPIN == "1" and { "Shopify/spin-hud" }) or nil,
  },
  colorscheme = "dracula",
  mappings = {
    n = {
      ["<leader>E"] = { "<cmd>e ~/.config/nvim/lua/user/init.lua<cr>", desc = "Edit init.lua" },
      ["n"] = { "nzz" },
      ["N"] = { "Nzz" },
    },
    t = {
      -- Ctrl-O in terminal to enter normal mode
      ["<C-O>"] = { "<C-\\><C-n>" },
    },
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
        opts.on_attach = function(client, buffer) setup_diagnostics(client, buffer) end
        return opts
      end,
    },
  },
}
