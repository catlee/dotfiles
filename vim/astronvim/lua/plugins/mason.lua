-- Customize Mason plugins

---@type LazySpec
return {
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      local root = require("lspconfig.util").root_pattern(".ruby-lsp", "Gemfile.lock")(vim.fn.getcwd())
      if root ~= nil then
        opts.install_root_dir = vim.fs.joinpath(root, ".ruby-lsp", "mason")
        vim.notify("setting mason dir to " .. opts.install_root_dir)
      end
      return opts
    end,
  },
  -- use mason-lspconfig to configure LSP installations
  {
    "williamboman/mason-lspconfig.nvim",
    -- dependencies = { "catlee/pull_diags.nvim" }, -- set up pull diagsnotics for LSPs
    dependencies = { "williamboman/mason.nvim" },
    -- overrides `require("mason-lspconfig").setup(...)`
    opts = function(_, opts)
      -- add more things to the ensure_installed table protecting against community packs modifying it
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
        "lua_ls",
        "jsonls",
        "yamlls",
        "ruby_lsp",
        "sorbet",
        "eslint",
      })
      opts.inlay_hints = { enabled = true }
    end,
  },
  -- use mason-null-ls to configure Formatters/Linter installation for null-ls sources
  {
    "jay-babu/mason-null-ls.nvim",
    -- overrides `require("mason-null-ls").setup(...)`
    opts = function(_, opts)
      -- add more things to the ensure_installed table protecting against community packs modifying it
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
        -- "prettier",
        "stylua",
        "jq",
      })
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    -- overrides `require("mason-nvim-dap").setup(...)`
    opts = function(_, opts)
      -- add more things to the ensure_installed table protecting against community packs modifying it
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
        -- "python",
        -- add more arguments for adding more debuggers
      })
    end,
  },
}
