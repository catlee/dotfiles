---@type LazySpec
return {
  -- For alternate file support
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
                { "components/[1]/app/**/[2].rb", "Misc" },
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
}
