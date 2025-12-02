return {
  {
    "chrishrb/gx.nvim",
    keys = { { "gx", "<cmd>Browse<cr>", mode = { "n", "x" } } },
    cmd = { "Browse" },
    init = function()
      vim.g.netrw_nogx = 1                      -- disable netrw gx
    end,
    submodules = false,                         -- not needed, submodules are required only for tests

    config = function()
      require("gx").setup {
        select_prompt = true, -- shows a prompt when multiple handlers match; disable to auto-select the top one

        handlers = {
          plugin = true,           -- open plugin links in lua (e.g. packer, lazy, ..)
          github = true,           -- open github issues
          package_json = true,     -- open dependencies from package.json
          go = true,               -- open pkg.go.dev from an import statement (uses treesitter)
          verdict_flag = {         -- custom handler to open rust's cargo packages
            name = "verdict_flag", -- set name of handler
            handle = function(mode, line, _)
              local flag = require("gx.helper").find(line, mode, "\"(f_.+)\"")

              if flag then
                return "https://experiments.shopify.com/flags/" .. flag
              end
            end,
          },
        },
      }
    end,
  },
}
