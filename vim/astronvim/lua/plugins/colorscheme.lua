---@type LazySpec
local theme_path = vim.fn.expand("~/.local/state/omarchy/current/theme/neovim.lua")
local theme_specs = {}

if vim.fn.filereadable(theme_path) == 1 then
  local ok, specs = pcall(dofile, theme_path)
  if ok and type(specs) == "table" then
    theme_specs = specs
  end
end

local theme_plugin = theme_specs[1]
local theme_options = theme_specs[2] and theme_specs[2].opts or {}
local colorscheme = theme_options.colorscheme or "astrodark"

local specs = {
  {
    "AstroNvim/astroui",
    opts = {
      colorscheme = colorscheme,
    },
  },
  {
    "rcarriga/nvim-notify",
    opts = {
      background_colour = "#000000",
    },
  },
}

if theme_plugin then
  table.insert(specs, 1, theme_plugin)
end

return specs
