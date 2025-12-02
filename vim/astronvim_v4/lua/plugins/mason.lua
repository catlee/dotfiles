---@type LazySpec

-- Function to generate a unique identifier for the current Ruby environment
local function get_ruby_env_hash()
  local components = {}

  -- Get Ruby executable path
  local ruby_path = vim.fn.system("which ruby 2>/dev/null"):gsub("\n", "")
  if ruby_path ~= "" then table.insert(components, ruby_path) end

  -- Get Ruby configuration digest
  local ruby_config = vim.fn
    .system([[ruby -e "require 'digest'; puts Digest::SHA256.hexdigest(RbConfig::CONFIG.to_s)" 2>/dev/null]])
    :gsub("\n", "")
  if ruby_config ~= "" then table.insert(components, ruby_config) end

  -- Include key environment variables that affect Ruby
  local env_vars = {
    "NIX_STORE",
    "NIX_PROFILES",
    "SHADOWENV_DATA",
    "RUBY_ROOT",
    "GEM_HOME",
    "GEM_PATH",
  }

  for _, var in ipairs(env_vars) do
    local value = vim.fn.getenv(var)
    if value and value ~= vim.NIL then table.insert(components, var .. "=" .. value) end
  end

  -- Create a hash from all components
  local combined = table.concat(components, "|")
  local hash = vim.fn.sha256(combined):sub(1, 8) -- Use first 8 chars of hash

  return hash
end

return {
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      -- Set up Ruby-environment-specific installation directory
      local ruby_hash = get_ruby_env_hash()
      local data_path = vim.fn.stdpath "data"
      opts.install_root_dir = data_path .. "/mason-ruby-" .. ruby_hash

      -- Log the installation directory for debugging
      vim.schedule(
        function() vim.notify("Mason using install dir: " .. opts.install_root_dir, vim.log.levels.DEBUG) end
      )

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

      -- Only enable ruby_lsp and sorbet for Ruby >= 2.7
      local ruby_version_output = vim.fn.system "ruby --version 2>/dev/null"
      if vim.v.shell_error == 0 then
        local major, minor = ruby_version_output:match "ruby (%d+)%.(%d+)"
        if major and minor then
          local version = tonumber(major) + tonumber(minor) / 10
          if version >= 2.7 then
            opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
              "ruby_lsp",
              "sorbet",
            })
          end
        end
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
