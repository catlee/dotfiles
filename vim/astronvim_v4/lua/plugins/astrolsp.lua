-- AstroLSP allows you to customize the features in AstroNvim's LSP configuration engine
-- Configuration documentation can be found with `:h astrolsp`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    -- Configuration table of features provided by AstroLSP
    features = {
      autoformat = true, -- enable or disable auto formatting on start
      codelens = true, -- enable/disable codelens refresh on start
      inlay_hints = false, -- enable/disable inlay hints on start
      semantic_tokens = true, -- enable/disable semantic token highlighting
    },
    -- customize lsp formatting options
    formatting = {
      -- control auto formatting on save
      format_on_save = {
        enabled = true, -- enable or disable format on save globally
        allow_filetypes = { -- enable format on save for specified filetypes only
          -- "go",
        },
        ignore_filetypes = { -- disable format on save for specified filetypes
          -- "python",
        },
      },
      disabled = { -- disable formatting capabilities for the listed language servers
        -- disable lua_ls formatting capability if you want to use StyLua to format your lua code
        -- "lua_ls",
        "yamlls",
        "vtsls",
        "tsserver",
        "typescript-tools",
        "ts_ls",
      },
      timeout_ms = 10000, -- default format timeout
      -- filter = function(client) -- fully override the default formatting function
      --   return true
      -- end
    },
    -- enable servers that you already have installed without mason
    servers = {
      -- "pyright"
    },
    -- customize language server configuration options passed to `lspconfig`
    ---@diagnostic disable: missing-fields
    config = {
      -- clangd = { capabilities = { offsetEncoding = "utf-8" } },
      ruby_lsp = {
        on_new_config = function(config)
          -- Get the Ruby-specific Mason installation directory
          local function get_ruby_env_hash()
            local components = {}
            local ruby_path = vim.fn.system("which ruby 2>/dev/null"):gsub("\n", "")
            if ruby_path ~= "" then table.insert(components, ruby_path) end
            local ruby_config = vim.fn
              .system([[ruby -e "require 'digest'; puts Digest::SHA256.hexdigest(RbConfig::CONFIG.to_s)" 2>/dev/null]])
              :gsub("\n", "")
            if ruby_config ~= "" then table.insert(components, ruby_config) end
            local env_vars = { "NIX_STORE", "NIX_PROFILES", "SHADOWENV_DATA", "RUBY_ROOT", "GEM_HOME", "GEM_PATH" }
            for _, var in ipairs(env_vars) do
              local value = vim.fn.getenv(var)
              if value and value ~= vim.NIL then table.insert(components, var .. "=" .. value) end
            end
            local combined = table.concat(components, "|")
            return vim.fn.sha256(combined):sub(1, 8)
          end

          local ruby_hash = get_ruby_env_hash()
          local data_path = vim.fn.stdpath "data"
          local mason_path = data_path .. "/mason-ruby-" .. ruby_hash
          local ruby_lsp_bin = mason_path .. "/bin/ruby-lsp"

          -- Check if the binary exists
          if vim.fn.executable(ruby_lsp_bin) == 1 then
            config.cmd = { ruby_lsp_bin }
          else
            -- Fallback to the default Mason bin path
            local default_bin = vim.fn.stdpath "data" .. "/mason/bin/ruby-lsp"
            if vim.fn.executable(default_bin) == 1 then config.cmd = { default_bin } end
          end
        end,
      },
      sorbet = {
        root_dir = require("lspconfig.util").root_pattern "sorbet/config",
        on_new_config = function(config)
          -- Similar setup for sorbet
          local function get_ruby_env_hash()
            local components = {}
            local ruby_path = vim.fn.system("which ruby 2>/dev/null"):gsub("\n", "")
            if ruby_path ~= "" then table.insert(components, ruby_path) end
            local ruby_config = vim.fn
              .system([[ruby -e "require 'digest'; puts Digest::SHA256.hexdigest(RbConfig::CONFIG.to_s)" 2>/dev/null]])
              :gsub("\n", "")
            if ruby_config ~= "" then table.insert(components, ruby_config) end
            local env_vars = { "NIX_STORE", "NIX_PROFILES", "SHADOWENV_DATA", "RUBY_ROOT", "GEM_HOME", "GEM_PATH" }
            for _, var in ipairs(env_vars) do
              local value = vim.fn.getenv(var)
              if value and value ~= vim.NIL then table.insert(components, var .. "=" .. value) end
            end
            local combined = table.concat(components, "|")
            return vim.fn.sha256(combined):sub(1, 8)
          end

          local ruby_hash = get_ruby_env_hash()
          local data_path = vim.fn.stdpath "data"
          local mason_path = data_path .. "/mason-ruby-" .. ruby_hash
          local srb_bin = mason_path .. "/bin/srb"

          -- Check if the binary exists
          if vim.fn.executable(srb_bin) == 1 then
            config.cmd = { srb_bin, "tc", "--lsp" }
          else
            -- Fallback to the default Mason bin path
            local default_bin = vim.fn.stdpath "data" .. "/mason/bin/srb"
            if vim.fn.executable(default_bin) == 1 then config.cmd = { default_bin, "tc", "--lsp" } end
          end
        end,
      },
      eslint = {
        root_dir = require("lspconfig.util").root_pattern "tsconfig.json",
      },
    },
    -- customize how language servers are attached
    handlers = {
      -- a function without a key is simply the default handler, functions take two parameters, the server name and the configured options table for that server
      -- function(server, opts) require("lspconfig")[server].setup(opts) end

      -- the key is the server that is being setup with `lspconfig`
      -- rust_analyzer = false, -- setting a handler to false will disable the set up of that language server
      -- pyright = function(_, opts) require("lspconfig").pyright.setup(opts) end -- or a custom handler function can be passed
    },
    -- Configure buffer local auto commands to add when attaching a language server
    autocmds = {
      -- first key is the `augroup` to add the auto commands to (:h augroup)
      lsp_document_highlight = {
        -- Optional condition to create/delete auto command group
        -- can either be a string of a client capability or a function of `fun(client, bufnr): boolean`
        -- condition will be resolved for each client on each execution and if it ever fails for all clients,
        -- the auto commands will be deleted for that buffer
        cond = "textDocument/documentHighlight",
        -- cond = function(client, bufnr) return client.name == "lua_ls" end,
        -- list of auto commands to set
        {
          -- events to trigger
          event = { "CursorHold", "CursorHoldI" },
          -- the rest of the autocmd options (:h nvim_create_autocmd)
          desc = "Document Highlighting",
          callback = function() vim.lsp.buf.document_highlight() end,
        },
        {
          event = { "CursorMoved", "CursorMovedI", "BufLeave" },
          desc = "Document Highlighting Clear",
          callback = function() vim.lsp.buf.clear_references() end,
        },
      },
    },
    -- mappings to be set up on attaching of a language server
    mappings = {
      n = {
        gl = { function() vim.diagnostic.open_float() end, desc = "Hover diagnostics" },
        -- a `cond` key can provided as the string of a server capability to be required to attach, or a function with `client` and `bufnr` parameters from the `on_attach` that returns a boolean
        -- gD = {
        --   function() vim.lsp.buf.declaration() end,
        --   desc = "Declaration of current symbol",
        --   cond = "textDocument/declaration",
        -- },
        -- ["<Leader>uY"] = {
        --   function() require("astrolsp.toggles").buffer_semantic_tokens() end,
        --   desc = "Toggle LSP semantic highlight (buffer)",
        --   cond = function(client) return client.server_capabilities.semanticTokensProvider and vim.lsp.semantic_tokens end,
        -- },
      },
    },
    -- A custom `on_attach` function to be run after the default `on_attach` function
    -- takes two parameters `client` and `bufnr`  (`:h lspconfig-setup`)
    -- on_attach = function(client, bufnr)
    -- this would disable semanticTokensProvider for all clients
    -- client.server_capabilities.semanticTokensProvider = nil
    -- end,
  },
}
