local ruby_version = vim.fn.executable "ruby" == 1 and vim.fn.system('ruby -e "puts RUBY_VERSION"'):gsub("\n", "")
  or nil

---@type LazySpec
return {
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      -- Hack to have different installations depending on ruby version
      -- Ideally mason would manage gem installations differently
      if ruby_version ~= nil then
        local path = require "mason-core.path"
        opts.install_root_dir = path.concat { tostring(vim.fn.stdpath "data"), "mason", "ruby", ruby_version }
        -- vim.notify("setting mason dir to " .. opts.install_root_dir)
        -- else
        --   vim.notify("`ruby` is not executable. Using default Mason installation directory.", vim.log.levels.WARN)
      end
      return opts
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
        "lua_ls",
        "jsonls",
        "yamlls",
        "eslint",
        "ts_ls",
      })

      if ruby_version and ruby_version >= "2.7" then
        opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
          "ruby_lsp",
          "sorbet",
        })
      end
      opts.inlay_hints = { enabled = true }
    end,
  },
  {
    "jay-babu/mason-null-ls.nvim",
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
        -- "stylua",
        "jq",
      })
    end,
  },
}
