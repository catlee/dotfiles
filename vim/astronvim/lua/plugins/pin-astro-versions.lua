-- Pin plugin versions for Neovim 0.12 compatibility
-- AstroNvim 6.x doesn't support Neovim 0.12 yet, so we pin to working versions
-- Remove this file once AstroNvim 7.x releases with Neovim 0.12 support

---@type LazySpec
return {
  { "AstroNvim/astrocore", commit = "5052189882442cf71e04ad2d5472ee31bfe6a5cf", pin = true },
  { "AstroNvim/astrolsp", commit = "0befe28a4ea96e46b7f7c01e4a634c04225ba55a", pin = true },
  { "AstroNvim/astroui", commit = "4943abbd42674b43249313afe83b91065a40e4be", pin = true },
  { "stevearc/aerial.nvim", commit = "645d108a5242ec7b378cbe643eb6d04d4223f034", pin = true }, -- v3.1.0 for Neovim 0.12
}
